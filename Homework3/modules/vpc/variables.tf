variable "vpc_cidr_block" {
  type        = string
  description = "The cidr block of the VPC, for example '10.0.0.0/16'"
}

variable "common_tags" {
  type = map(any)
}

variable "env_name" {
  type        = string
  description = "Environment name, for example - 'Prod'"
}
