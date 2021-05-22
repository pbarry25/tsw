#!/usr/bin/env bash
#
# Run tsw.py through its paces...

function run_test() {
	TEST_CMD="${1}"
	TEST_MSG="${2}"
	EXPECTED_CODE=${3}

	eval ${TEST_CMD} > /dev/null
	RET_CODE=${?}
	if [ ${RET_CODE} -ne ${EXPECTED_CODE} ]; then
		echo
		echo
		echo "ERROR with ${TEST_MSG}: expected exit code ${EXPECTED_CODE}, received ${RET_CODE}"
		echo "    failed test cmdline: ${TEST_CMD}"
		exit 2
	fi
}

TARGET_URL="https://raw.githubusercontent.com/pbarry25/tsw/main/LICENSE"
EXPECTED_SUM="620f9d32b2f1c11a1cd45181ba6ea055ff206b27"
EXPECTED_SHA224_SUM="c68a2c49c3a32fbf5485efabbb2aa442a683ee39af3d6c85879db77a"
EXPECTED_SHA256_SUM="e5784e879dc2c2a720bb0f71481d93de71e1a1a865ce5d8d008b208bc595033a"
EXPECTED_SHA384_SUM="20b027b17d965b44e0f7b9b22b74cfea5b3aa2a7cccbbc22e3546e8301eac57e0ff8f2dc14fab360938c49d1d42f2676"
EXPECTED_SHA512_SUM="f0dbb9b29ae3e0d33286b76da6f6d75439b4099f67fe59a2bc6c185ee33027bd4c25131590dec9149ba031821e725ff980c9d2df68cff559c475b4bd50180e09"

echo -n "Testing success outcomes... "

run_test "TARGET_URL=\"${TARGET_URL}\" EXPECTED_SUM=\"${EXPECTED_SUM}\" ./tsw.py" "SHA1SUM test" 0

run_test "TARGET_URL=\"${TARGET_URL}\" EXPECTED_SHA224_SUM=\"${EXPECTED_SHA224_SUM}\" ./tsw.py" "SHA224SUM test" 0

run_test "TARGET_URL=\"${TARGET_URL}\" EXPECTED_SHA256_SUM=\"${EXPECTED_SHA256_SUM}\" ./tsw.py" "SHA256SUM test" 0

run_test "TARGET_URL=\"${TARGET_URL}\" EXPECTED_SHA384_SUM=\"${EXPECTED_SHA384_SUM}\" ./tsw.py" "SHA384SUM test" 0

run_test "TARGET_URL=\"${TARGET_URL}\" EXPECTED_SHA512_SUM=\"${EXPECTED_SHA512_SUM}\" ./tsw.py" "SHA512SUM test" 0

run_test "TARGET_URL=\"${TARGET_URL}\" EXPECTED_SUM=\"${EXPECTED_SUM}\" EXPECTED_SHA224_SUM=\"${EXPECTED_SHA224_SUM}\" EXPECTED_SHA256_SUM=\"${EXPECTED_SHA256_SUM}\" EXPECTED_SHA384_SUM=\"${EXPECTED_SHA384_SUM}\" EXPECTED_SHA512_SUM=\"${EXPECTED_SHA512_SUM}\" ./tsw.py" "SHA-ALL-SUM test" 0

echo "Done."
echo -n "Testing failure outcomes... "
set +e

# Missing sum
run_test "TARGET_URL=\"${TARGET_URL}\" ./tsw.py" "missing sum test" 4

# Invalid URL
run_test "TARGET_URL=\"https://raw.githubusercontent.com/pbarry25/tsw/main/LICENS\" EXPECTED_SUM=\"620f9d32b2f1c11a1cd45181ba6ea055ff206b27\" ./tsw.py" "invalid URL test" 2

# Incorrect sum
run_test "TARGET_URL=\"${TARGET_URL}\" EXPECTED_SUM=\"asd\" ./tsw.py" "SHA1SUM mismatch test" 3

echo "Done."

exit 0
