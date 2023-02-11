output "public_subnets" {
  value = "aws_subnets.public_subnets"
}

output "private_subnets" {
  value = "aws_subnets.private_subnets"
}

output "security_group" {
  value = "aws_security_group.allow-all"
}
