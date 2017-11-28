provider "aws" {
  region  = "${var.aws_region}"
  profile = "${var.aws_profile}"
}

# --------------------------------------------------------------------------------------------------------------
# various data lookups
# --------------------------------------------------------------------------------------------------------------
data "aws_ami" "target_ami" {
  most_recent = true

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }

  filter {
    name   = "name"
    values = ["${var.nifi_ami_name}"]
  }
}

data "aws_subnet" "bastion_subnet" {
  cidr_block = "${var.bastion_subnet_cidr}"
}

data "aws_vpc" "bastion_vpc" {
  cidr_block = "${var.bastion_vpc_cidr}"
}

data "aws_iam_policy_document" "ec2-service-role-policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

# TODO: parameterise that nacl
variable "default_network_acl_id" {
  default = "acl-6c6a2f05"
}

# ----------------------------------------------------------------------------------------
# instance for NIFI.
# ----------------------------------------------------------------------------------------

resource "aws_instance" "nifi" {
  ami                    = "${data.aws_ami.target_ami.id}"
  instance_type          = "${var.nifi_instance_type}"
  key_name               = "${var.nifi_key}"
  subnet_id              = "${data.aws_subnet.bastion_subnet.id}"
  vpc_security_group_ids = ["${aws_security_group.nifi_access.id}", "${aws_security_group.nifi_ssh.id}"]

  iam_instance_profile = "${aws_iam_instance_profile.nifi_profile.name}"

  root_block_device = {
    volume_type = "gp2"
    volume_size = "${var.root_vol_size}"
  }

  tags {
    Name    = "NiFi"
    Project = "${var.tags["project"]}"
    Owner   = "${var.tags["owner"]}"
    Client  = "${var.tags["client"]}"
  }

  volume_tags {
    Project = "${var.tags["project"]}"
    Owner   = "${var.tags["owner"]}"
    Client  = "${var.tags["client"]}"
  }

  user_data = <<EOF
#!/bin/bash
yum update -y
yum install -y java-1.8.0-openjdk
yum remove -y java-1.7.0-openjdk
adduser nifi
sudo -u nifi sh -c 'cd ~nifi; wget -q http://mirrors.rackhosting.com/apache/nifi/1.4.0/nifi-1.4.0-bin.tar.gz'
sudo -u nifi sh -c 'cd ~nifi; tar xfz nifi*tar.gz'
sudo -u nifi sh -c 'cd ~nifi; ln -s nifi-1.4.0 nifi'
~nifi/nifi/bin/nifi.sh install
printf "\n\nexport JAVA_HOME=/usr/lib/jvm/jre-1.8.0-openjdk\n" >> ~nifi/nifi/bin/nifi-env.sh
sed -i 's/run.as=.*/run.as=nifi/' ~nifi/nifi/conf/bootstrap.conf
service nifi start
EOF
}

resource "aws_security_group" "nifi_access" {
  name        = "nifi_access"
  description = "allows access to nifi"
  vpc_id      = "${data.aws_vpc.bastion_vpc.id}"

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = "${var.nifi_inbound}"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "nifi_ssh" {
  name        = "nifi_ssh"
  description = "allows ssh to nifi"
  vpc_id      = "${data.aws_vpc.bastion_vpc.id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = "${var.nifi_inbound}"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_iam_role" "nifi_role" {
  name_prefix           = "nifi"
  path                  = "/"
  description           = "roles polices the nifi instance can use"
  force_detach_policies = true
  assume_role_policy    = "${data.aws_iam_policy_document.ec2-service-role-policy.json}"
}

resource "aws_iam_instance_profile" "nifi_profile" {
  name_prefix = "nifi"
  role        = "${aws_iam_role.nifi_role.name}"
}

// TODO: "sudo service nifi start"
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
    bucket_arn = "${aws_s3_bucket.s3_landing.arn}"
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
    bucket_arn = "${aws_s3_bucket.s3_landing.arn}"
    queue_arn  = "${aws_sqs_queue.s3_landing_queue.arn}"
  }
}

resource "aws_sqs_queue_policy" "s3_landing_policy" {
  queue_url = "${aws_sqs_queue.s3_landing_queue.id}"
  policy    = "${data.template_file.sqs_policy.rendered}"
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = "${aws_s3_bucket.s3_landing.id}"

  queue {
    queue_arn = "${aws_sqs_queue.s3_landing_queue.arn}"
    events    = ["s3:ObjectCreated:*"]
  }
}
