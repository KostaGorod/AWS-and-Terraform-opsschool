

variable "aws_region" {
  default = "us-east-1"
  type    = string
}

variable "instance_type" {
  description = "The type of the ec2, for example - t2.medium"
  default     = "t2.micro"
  type        = string
}

variable "key_name" {
  default     = "hw3"
  description = "The key name of the Key Pair to use for the instance"
  type        = string
}

variable "ubuntu_account_number" {
  description = "The AWS account number of the offical Ubuntu Images"
  default     = "099720109477"
  type        = string
}

variable "nginx_instances_count" {
  description = "The number of Nginx instances to create"
  default     = 1
}

variable "DB_instances_count" {
  description = "The number of DB instances to create"
  default     = 2
}


variable "volumes_type" {
  description = "The type of all the disk instances in my project"
  default     = "gp2"
}

variable "owner_tag" {
  description = "The owner tag will be applied to every resource in the project through the 'default variables' feature"
  default     = "Ops-School"
  type        = string
}
variable "purpose_tag" {
  default = "Whiskey"
  type    = string
}
