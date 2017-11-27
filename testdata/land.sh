#!/bin/bash

cd $(dirname $0)

. ../bootstrap-scripts/env.rc

BUCKET=lb-nifi-demo-landing20171124175225028000000002

for FIL in $(ls *.txt)
do 
  aws s3 cp $FIL s3://$BUCKET/input/ \
    --sse --storage-class REDUCED_REDUNDANCY \
    --metadata owner=rahook,project=work-nifi,client=Internal
done
