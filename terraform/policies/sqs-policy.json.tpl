{
   "Version": "2012-10-17",
   "Statement": [
     {
       "Effect": "Allow",
       "Principal": "*",
       "Action": "SQS:SendMessage",
       "Resource": "${queue_arn}",
       "Condition": {
         "ArnEquals": {
           "aws:SourceArn": "${bucket_arn}"
         }
       }
     }
   ]
}
