variable "tags" {
  default = {
    "owner"   = "rahook"
    "project" = "work-nifi"
    "client"  = "Internal"
  }
}

variable "nifi_inbound" {
  type    = "list"
  default = ["88.98.202.26.0/24", "188.183.134.0/24"]
}

/* variables to inject via terraform.tfvars */
variable "aws_region" {}

variable "aws_account_id" {}
variable "aws_profile" {}
variable "nifi_key" {}
variable "landing_bucket" {}
variable "output_bucket" {}
