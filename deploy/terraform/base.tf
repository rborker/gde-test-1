
variable "region" {default="us-east-1"}

provider "aws" {
  region = "${var.region}"
}

terraform {
  backend "s3" {
    bucket = "gigster-network-terraform"
    key    = "test-gig/terraform.tfstate"
    region = "us-east-1"
  }
}
