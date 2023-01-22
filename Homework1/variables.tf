variable "aws_region" {
  description = "AWS region"
  default     = "us-east-1"
}

variable "instance_aws_ami" {
    description = "AWS ami ID"
   default = "ami-0b5eea76982371e91" # Amazon Linux 2 AMI (HVM)(x64) - Kernel 5.10, SSD Volume Type
}

variable "instance_type" {
   description = "Type of AWS EC2 instance"
   default     = "t3.micro"
}

variable "instance_count" {
   default = 2
}