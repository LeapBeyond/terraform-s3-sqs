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

# ----------------------------------------------------------------------------------------
# SQS queue
# ----------------------------------------------------------------------------------------

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

data "template_file" "sqs_policy" {
  template = "${file("policies/sqs-policy.json.tpl")}"

  vars {
    bucket_arn  = "${aws_s3_bucket.s3_landing.arn}"
    queue_arn = "${aws_sqs_queue.s3_landing_queue.arn}"
  }
}

resource "aws_sqs_queue_policy" "s3_landing_policy" {
  queue_url = "${aws_sqs_queue.s3_landing_queue.id}"
  policy = "${data.template_file.sqs_policy.rendered}"
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = "${aws_s3_bucket.s3_landing.id}"

  queue {
    queue_arn     = "${aws_sqs_queue.s3_landing_queue.arn}"
    events        = ["s3:ObjectCreated:*"]
  }
}
