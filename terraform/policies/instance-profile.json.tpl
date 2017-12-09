{
   "Version":"2012-10-17",
   "Statement":[
      {
         "Effect":"Allow",
         "Action":[
            "s3:ListBucketByTags",
            "s3:GetLifecycleConfiguration",
            "s3:GetBucketTagging",
            "s3:GetInventoryConfiguration",
            "s3:GetObjectVersionTagging",
            "s3:ListBucketVersions",
            "s3:GetBucketLogging",
            "s3:ListBucket",
            "s3:GetAccelerateConfiguration",
            "s3:GetBucketPolicy",
            "s3:GetObjectVersionTorrent",
            "s3:GetObjectAcl",
            "s3:GetBucketRequestPayment",
            "s3:GetObjectVersionAcl",
            "s3:GetObjectTagging",
            "s3:GetMetricsConfiguration",
            "s3:GetIpConfiguration",
            "s3:ListBucketMultipartUploads",
            "s3:GetBucketWebsite",
            "s3:GetBucketVersioning",
            "s3:GetBucketAcl",
            "s3:GetBucketNotification",
            "s3:GetReplicationConfiguration",
            "s3:ListMultipartUploadParts",
            "s3:GetObject",
            "s3:GetObjectTorrent",
            "s3:GetBucketCORS",
            "s3:GetAnalyticsConfiguration",
            "s3:GetObjectVersionForReplication",
            "s3:GetBucketLocation",
            "s3:GetObjectVersion"
         ],
         "Resource":[ "${bucket_arn}", "${bucket_arn}/*" ]
      },
      {
         "Effect":"Allow",
         "Action":[
            "s3:PutObject",
            "s3:ListBucket"
         ],
         "Resource":[ "${output_bucket_arn}/*", "${output_bucket_arn}" ]
      },
      {
         "Effect":"Allow",
         "Action":[
            "s3:ListAllMyBuckets",
            "s3:HeadBucket",
            "s3:ListObjects"
         ],
         "Resource":"*"
      },
      {
         "Effect":"Allow",
         "Action":[
            "sqs:ReceiveMessage",
            "sqs:ListQueueTags",
            "sqs:GetQueueUrl",
            "sqs:GetQueueAttributes",
            "sqs:ListDeadLetterSourceQueues"
         ],
         "Resource":"${queue_arn}"
      },
      {
         "Effect":"Allow",
         "Action":[
            "sqs:ListQueues"
         ],
         "Resource":"*"
      }
   ]
}
