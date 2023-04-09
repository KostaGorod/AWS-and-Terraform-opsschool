terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.7" #added support for 'user_data_replace_on_change'
    }
  }
  cloud {
    # hostname     = "app.terraform.io"
    organization = "kosta"

    workspaces {
      name = "AWS-and-Terraform-opsschool"
    }
  }
}

provider "aws" {
  # profile = "ec2admin"
  region = var.aws_region
  # shared_config_files      = ["~/.aws/config"]
  # shared_credentials_files = ["~/.aws/credentials"]
  default_tags {
    tags = {
      # Owner   = var.owner_tag
      Purpose = var.purpose_tag
    }
  }
}
