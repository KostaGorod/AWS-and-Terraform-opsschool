terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.7" #added support for 'user_data_replace_on_change'
    }
  }
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

provider "aws" {
  region = var.aws_region
}




resource "aws_security_group" "allow_http" {
  name = "allow_http"
  # HTTP access from anywhere
  ingress {
    from_port        = 80
    to_port          = 80
    protocol         = "TCP"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "app_server" {
  count                       = 2
  ami                         = "ami-0b5eea76982371e91"
  instance_type               = "t3.micro"
  security_groups             = [aws_security_group.allow_http.name] #can't be declared by id
  user_data_replace_on_change = true
  ebs_block_device {
    device_name = "/dev/sdf"
    volume_size = 10
    encrypted   = true
  }
  user_data = file("init-script.sh")

  tags = {
    Name    = "Whiskey_website-${count.index}"
    Owner   = "Kosta"
    Purpose = "Whiskey"
  }
}