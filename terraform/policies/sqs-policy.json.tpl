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
     },

     {
       "Sid": "Sid1487080416052",
       "Effect": "Allow",
       "Principal": {
         "AWS": "arn:aws:iam::568794283665:user/rahook_admin_cli"
       },
       "Action": [
         "SQS:ReceiveMessage",
         "SQS:DeleteMessage",
         "SQS:GetQueueAttributes"
       ],
       "Resource": "${queue_arn}"
     }
   ]
}
