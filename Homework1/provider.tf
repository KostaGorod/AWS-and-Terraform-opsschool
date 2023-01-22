terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.7" #added support for 'user_data_replace_on_change'
    }
  }
}

provider "aws" {
  region  = var.aws_region
  profile = "cloud9"
}