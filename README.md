# terraform-s3-sqs

This project is intended to support the creation of some assets and an environment for demonstrating NiFi.

It creates an input and output S3 bucket, some SQS artefacts, and an EC2 box on which to run NiFi for the demonstration.

This assumes that you are running with a suitable AWS account referenced by it's profile.

## Usage
The top level `setup.sh` and `teardown.sh` scripts can be executed (as long as the `env.rc` in `bootstrap-scripts` has been setup correctly) to run up
and tear down the assets.

Before executing these, you will need to take note of the instructions around `env.rc` inside the `bootstrap-scripts` folder.

*TODO:* fill this out with notes on usage, constraints and so forth.
