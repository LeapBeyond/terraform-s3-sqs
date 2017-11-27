provider "aws" {
  region  = "${var.aws_region}"
  profile = "${var.aws_profile}"
}

# ----------------------------------------------------------------------------------------
# some S3 buckets.
# ----------------------------------------------------------------------------------------
resource "aws_s3_bucket" "s3_landing" {
  bucket_prefix = "${var.landing_bucket}"
  acl           = "private"
  region        = "${var.aws_region}"

  tags {
    Name    = "s3_landing"
    Project = "${var.tags["project"]}"
    Owner   = "${var.tags["owner"]}"
    Client  = "${var.tags["client"]}"
  }
}

resource "aws_s3_bucket" "s3_output" {
  bucket_prefix = "${var.output_bucket}"
  acl           = "private"
  region        = "${var.aws_region}"

  tags {
    Name    = "s3_output"
    Project = "${var.tags["project"]}"
    Owner   = "${var.tags["owner"]}"
    Client  = "${var.tags["client"]}"
  }
}

# ----------------------------------------------------------------------------------------
# dropzone bucket policies
# ----------------------------------------------------------------------------------------

data "template_file" "dropzone_write" {
  template = "${file("policies/s3-dropzone-policy.json.tpl")}"

  vars {
    bucket_arn  = "${aws_s3_bucket.s3_landing.arn}"
  }
}

resource "aws_s3_bucket_policy" "dropzone_write" {
  bucket = "${aws_s3_bucket.s3_landing.id}"
  policy = "${data.template_file.dropzone_write.rendered}"
}

# ----------------------------------------------------------------------------------------
# output bucket policies
# ----------------------------------------------------------------------------------------

/*
resource "aws_s3_bucket_policy" "b" {
  bucket = "${aws_s3_bucket.b.id}"
  policy =<<POLICY
{
  "Version": "2012-10-17",
  "Id": "MYBUCKETPOLICY",
  "Statement": [
    {
      "Sid": "IPAllow",
      "Effect": "Deny",
      "Principal": "*",
      "Action": "s3:*",
      "Resource": "arn:aws:s3:::my_tf_test_bucket/*",
      "Condition": {
         "IpAddress": {"aws:SourceIp": "8.8.8.8/32"}
      }
    }
  ]
}
POLICY
}
*/

resource "aws_sqs_queue" "s3_landing_queue" {
  name_prefix = "nifi_demo"

  visibility_timeout_seconds = 60

  tags {
    Name    = "s3_landing_queue"
    Project = "${var.tags["project"]}"
    Owner   = "${var.tags["owner"]}"
    Client  = "${var.tags["client"]}"
  }
}

# resource "aws_sqs_queue_policy" "s3_landing_policy" {
#   queue_url = "${aws_sqs_queue.s3_landing_queue.id}"
#   policy = <<POLICY
# {
#   "Version": "2012-10-17",
#   "Id": "arn:aws:sqs:eu-west-1:637081851720:poc_s3_landing/SQSDefaultPolicy",
#   "Statement": [
#     {
#       "Sid": "Sid1487071327559",
#       "Effect": "Allow",
#       "Principal": "*",
#       "Action": "SQS:SendMessage",
#       "Resource": "arn:aws:sqs:eu-west-1:637081851720:poc_s3_landing",
#       "Condition": {
#         "ArnLike": {
#           "aws:SourceArn": "arn:aws:s3:*:*:pocingestnhsd"
#         }
#       }
#     },
#     {
#       "Sid": "Sid1487080416052",
#       "Effect": "Allow",
#       "Principal": {
#         "AWS": "arn:aws:iam::637081851720:user/cds.provider"
#       },
#       "Action": [
#         "SQS:ReceiveMessage",
#         "SQS:DeleteMessage",
#         "SQS:GetQueueAttributes"
#       ],
#       "Resource": "arn:aws:sqs:eu-west-1:637081851720:poc_s3_landing"
#     }
#   ]
# }
# POLICY
# }
