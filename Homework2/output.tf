output "aws_instance_public_dns" {
  value = aws_instance.webserver[*].public_dns
}   