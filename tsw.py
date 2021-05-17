#!/usr/bin/env python3
#
# Strive to follow PEP8 style suggestions:
#   https://www.python.org/dev/peps/pep-0008

### Imports
import json
import os
from enum import Enum, auto
import urllib.request
import hashlib

### Classes
class SumRetCodes(Enum):
    RequestError = auto()
    Matched = auto()
    Mismatched = auto()

class AWSLambdaRequestError(Exception): pass
class AWSLambdaSumMismatched(Exception): pass

### Globals
VERSION = "0.1"
TARGET_URL = os.environ["TARGET_URL"]
EXPECTED_SUM = os.environ.get("EXPECTED_SUM", None)
EXPECTED_SHA256_SUM = os.environ.get("EXPECTED_SHA256_SUM", None)

### Code

# Retrieve file at 'target' URL, sum it, verify it is the expected sum...
def sum_file(target, expected, read_size = 10000):
    read_finished = False
    try:
        response = urllib.request.urlopen(target)
        read_byte_cnt = 0
        # create hashers
        sums = {algo: hashlib.new(algo) for algo, digest in expected.items() if digest}
        while True:
            data = response.read(read_size)
            if len(data) == 0:
                if read_byte_cnt > 0:
                    # Only say we're done if we read SOMETHING...
                    read_finished = True
                break
            # update all sums
            for sum in sums.values():
                sum.update(data)
            read_byte_cnt = read_byte_cnt + len(data)
    except:
        # Serverless (AWS Lambda) won't make it here, check below...
        return SumRetCodes.RequestError
    if read_finished is not True:
        # This covers AWS Lambda having an issue in retrieving and summing the target...
        return SumRetCodes.RequestError
    for algo, sum in sums.items():
        print(algo, sum.hexdigest(), expected[algo])
        if sum.hexdigest() != expected[algo]:
            return SumRetCodes.Mismatched
    return SumRetCodes.Matched

# Amazon Lambda entry point...
def lambda_handler(event, context):
    ret = sum_file(TARGET_URL, {
        'sha1': EXPECTED_SUM,
        'sha256': EXPECTED_SHA256_SUM})
    if ret == SumRetCodes.RequestError:
        raise(AWSLambdaRequestError("Failed to read file at TARGET_URL"))
    elif ret == SumRetCodes.Mismatched:
        raise(AWSLambdaSumMismatched("Artifact checksums did NOT match"))
    return "200 OK"

# Standalone script entry point...
if __name__ == "__main__":
    ret = sum_file(TARGET_URL, {
        'sha1': EXPECTED_SUM,
        'sha256': EXPECTED_SHA256_SUM})
    if ret == SumRetCodes.RequestError:
        exit(2)
    elif ret == SumRetCodes.Mismatched:
        exit(3)

    # If we made it here, the sums matched...
    exit(0)
