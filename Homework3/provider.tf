terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.7" #added support for 'user_data_replace_on_change'
    }
  }
}

provider "aws" {
  profile = "cloud9"
  region  = var.aws_region
  default_tags {
    tags = {
      Owner   = var.owner_tag
      Purpose = var.purpose_tag
    }
  }
}
