#!/bin/bash

cd $(dirname $0)/bootstrap-scripts

./bootstrap.sh

cd ../terraform

terraform init
terraform apply
