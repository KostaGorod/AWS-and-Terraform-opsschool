variable "vpc_cidr_block" {
  type        = string
  description = "The cidr block of the VPC, for example '10.0.0.0/16'"
}

variable "private_subnets_cidr_list" {
  type        = list(string)
  description = "List of private subnets for the VPC, for ex- ['10.0.2.0/24', '10.0.3.0/24']"
}

variable "public_subnets_cidr_list" {
  type        = list(string)
  description = "List of public subnets for the VPC, for ex- ['10.0.100.0/24', '10.0.101.0/24']"
}

variable "APP_NAME" {
  type        = string
  description = "the Application Name, For example - 'Whiskey-Site'"
}

variable "ENV" {
  type        = string
  description = "Environment name, for example - 'Prod'"
}

# variable "AWS_REGION" {
#   type        = string
#   description = "AWS Region for the VPC"
# }

# variable "ingress_tcp_ports_public_subnets" {
#   type        = list(string)
#   description = "list of TCP ports to open in the Public subnets"
# }
