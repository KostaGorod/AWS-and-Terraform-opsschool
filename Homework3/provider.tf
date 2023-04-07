terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.7" #added support for 'user_data_replace_on_change'
    }
  }
  backend "s3" {
    bucket  = "kg-opsschool9-terraform-state"
    key     = "aws-and-terraform-state-hw3"
    region  = "us-east-1"
    profile = "ec2admin"
  }
}

provider "aws" {
  profile                  = "ec2admin"
  region                   = var.aws_region
  shared_config_files      = ["~/.aws/config"]
  shared_credentials_files = ["~/.aws/credentials"]
  default_tags {
    tags = {
      # Owner   = var.owner_tag
      Purpose = var.purpose_tag
    }
  }
}
