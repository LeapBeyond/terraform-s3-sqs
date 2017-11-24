#!/bin/bash

cd `dirname $0`
[ -d ../data ] || mkdir ../data
[[ -s ./env.rc ]] && source ./env.rc

echo "======= removing key pairs ======="
for KEY_NAME in $KEY_NAMES
do
  aws ec2 describe-key-pairs --output text --key-name $KEY_NAME >/dev/null 2>&1
  if [ $? -eq 0 ]
  then
    aws ec2 delete-key-pair --key-name $KEY_NAME
    rm -f ../data/$KEY_NAME.pem
  fi
done

aws ec2 describe-key-pairs
