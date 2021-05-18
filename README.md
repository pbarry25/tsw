# TSW

## Description

TSW is a simple early-warning system to detect-and-alert when any files/artifacts for download change unexpectedly, providing awareness in the event of a compromise or other unexpected change. It is currently written in Python 3 and is designed to be run as an AWS Lambda (i.e. serverless) process or as a process on a standard system with Python 3 installed. Hopefully it works with other serverless technologies!

### Goals of this project

In no particular order:

* keep this code straight-forward to read+understand
* keep this code simple:
   * only rely on Python 3 standard libraries
   * rely on external mechanisms to trigger/schedule the script (don't build into this code!)
   * rely on external mechanisms to take alert actions (don't build into this code!)
* maintain ease-of-use for users

### How to use

TSW is really just one file: `tsw.py`, and only requires a standard Python 3 installation to work. This section calls out two supported installation methods, though other ways to install+use certainly exist.

Any expected sum values that are omitted are not checked, e.g. using just EXPECTED_SHA256_SUM will only validate the SHA256 sum, but not the SHA1.

#### AWS Lambda (serverless)

1. Create a new AWS Lambda python 3 application
1. Copy the `tsw.py` code in for the Lambda code
1. Add two config environment variables with the following Key:Value settings
   * TARGET_URL: <the URL of the artifact you want verified hasn't changed>
   * EXPECTED_SUM: <the sha1 sum you are expecting the artifact to match, hex string format> (optional)
   * EXPECTED_SHA256_SUM: <the sha256 sum you are expecting the artifact to match, hex string format> (optional)

At this point, you can add a [time-based trigger](https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-run-lambda-schedule.html) for your Lambda or whatever you like there. You can also set up [monitoring to take actions](https://aws.amazon.com/getting-started/hands-on/handle-serverless-application-errors-step-functions-lambda/) (like alerting!) when the current sum does not match the expected sum.

#### Linux

You can manually run TSW on a Linux commandline like so:

`TARGET_URL="<http/https URL to hosted artifact to check>" EXPECTED_SUM="<sha1sum hex string value>" EXPECTED_SHA256_SUM="<sha256sum hex string value> ./tsw.py`

Example passing run:

```
$ TARGET_URL="https://raw.githubusercontent.com/pbarry25/tsw/main/LICENSE" EXPECTED_SUM="620f9d32b2f1c11a1cd45181ba6ea055ff206b27" EXPECTED_SHA256_SUM="e5784e879dc2c2a720bb0f71481d93de71e1a1a865ce5d8d008b208bc595033a" ./tsw.py
sha1 620f9d32b2f1c11a1cd45181ba6ea055ff206b27 620f9d32b2f1c11a1cd45181ba6ea055ff206b27
sha256 e5784e879dc2c2a720bb0f71481d93de71e1a1a865ce5d8d008b208bc595033a e5784e879dc2c2a720bb0f71481d93de71e1a1a865ce5d8d008b208bc595033a
$ echo $?
0
```

You can setup a periodic running of your script via [cron](https://opensource.com/article/17/11/how-use-cron-linux). Additionally, cron [can email you](https://askubuntu.com/questions/418237/how-to-detect-error-in-cron-jobs) when `tsw.py` returns an error (like sum mismatch!).

As a random datapoint, you can currently get a dedicated EC2 ARM 64 t4g.nano Linux instance in AWS for less than $4/month. And an ECS container should be even cheaper...!

### Potential improvements

Living list of future ideas:

* Improve docs
* Add additional sum options
* Improve exception handling
* Add support for installation via `pip`
* Add support for other popular serverless technologies
* Add support for CLI tools and things like TerraForm to automate deployment and setup
* Add support for container technologies
* Add support for PGP/GPG [signature verification](https://web.archive.org/web/20201111230210/https://www.gnupg.org/gph/en/manual/x135.html)

### Intentional non-improvements

Living list of things not planned (up for debate!):

* Better integration with CI/CD to update expected sum as part of an automated workflow
  * While manual updating of the expected sum kinda stinks, avoiding explicit linking between your existing CI/CD and your TSW instance will avoid disclosing the TSW existance to attackers should your CI/CD become compromised, allowing TSW a chance to catch any artifact manipulation attackers may perform

## Name and impetus

The project name comes from the three-letter broadcast code of the [Emergency Alert System (EAS)](https://web.archive.org/web/20210419131359/https://www.weather.gov/nwr/eventcodes) to warn of tsunamis. The impetus/inspriation of this bit of work was the [codecov supply chain attack](https://web.archive.org/web/20210421181028/https://thenewstack.io/not-your-usual-supply-chain-hack-the-codecov-bash-uploader-blunder/), which utilized a modified download file that went undetected and leaked a bunch of sensitive user data --like credentials-- to an unauthorized party.
