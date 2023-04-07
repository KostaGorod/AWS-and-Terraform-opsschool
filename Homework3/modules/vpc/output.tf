output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnets_id" {
  #value = "aws_subnet.public_subnet[*].id"
  value = [for subnet in aws_subnet.public_subnet : subnet.id]
}

output "private_subnets_id" {
  #value = "aws_subnets.private_subnet[*].id"
  value = [for subnet in aws_subnet.private_subnet : subnet.id]
}
output "security_group" {
  value = "aws_security_group.allow-all"
}

output "my_nat_gw" {
  value = aws_nat_gateway.nat_gw
}


output "vpc_cidr_block" {
  value = aws_vpc.main.cidr_block
}
