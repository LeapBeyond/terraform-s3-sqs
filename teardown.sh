#!/bin/bash

cd $(dirname $0)/terraform
terraform destroy -force

cd ../bootstrap-scripts
./teardown.sh
