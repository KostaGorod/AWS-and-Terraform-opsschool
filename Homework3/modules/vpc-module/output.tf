output "public_subnets_id" {
  value = aws_subnet.public.*.id
}

output "private_subnets_id" {
  value = aws_subnet.private.*.id
}

output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "vpc_cidr" {
  value = aws_vpc.vpc.cidr_block
}
