output "aws_instance_public_dns" {
  value = aws_instance.app_server[*].public_dns
}   