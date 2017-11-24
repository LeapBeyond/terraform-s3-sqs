#!/bin/bash

cd $(dirname $0)/bootstrap-scripts

./teardown.sh

cd ../terraform

pwd
ls -al ../data
