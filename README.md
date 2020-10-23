# terraform-s3-sqs

This project is intended to support the creation of some assets and an environment for demonstrating NiFi.

It creates an input and output S3 bucket, some SQS artefacts, and an EC2 box on which to run NiFi for the demonstration.

This assumes that you are running with a suitable AWS account referenced by it's profile.

## Usage
The top level `setup.sh` and `teardown.sh` scripts can be executed (as long as the `env.rc` in `bootstrap-scripts` has been setup correctly) to run up
and tear down the assets.

Before executing these, you will need to take note of the instructions around `env.rc` inside the `bootstrap-scripts` folder.

The Terraform scripts set up an EC2 instance with NiFi installed, an S3 landing zone bucket and an S3 output bucket. There is also an SQS queue. In the `nifi` folder you will find a template `word-count-example.xml` that can be imported to the instance through the NiFi console. The S3 landing zone bucket puts a message on the queue for landed files, and the template watches this queue. On receiving a notification of a new file, it retrieves the file, does a frequency count on words in it, and writes the frequency count to the output bucket.

This set of scripts illustrates how to set up basic security for this sort of pipeline, although the security is still a bit more broad than may be strictly needed.

Note that it takes a non-trivial time for NiFi to be downloaded, installed and started - the EC2 instance will be available long before the bootstrap script has finished doing this work. Once finished, NiFi will be available at `http://<instance address>:8080/nifi`. The first thing you need to do is import the template and apply it. The `GetSQS` processor will need to be updated with the correct SQS Queue URL, and similarly the two S3 processors need to be updated with the correct bucket names.

An additional bit of NiFi manual fiddling - an `AWSCredentialsProviderControllerService` has to be added to the running instance so that NiFi will use the instance role, and all three of the AWS processors updated to use this provider.

*TODO:* There is currently a bug, and NiFi is not correctly accessing SQS using the EC2 role - the role itself is working for the `nifi` user, but somehow the NiFi glue code is passing along an invalid request

## License
Copyright 2017 Leap Beyond Emerging Technologies B.V.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

   http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
