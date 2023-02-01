data "aws_ami" "aws_linux2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-5*-hvm-*-x86_64-gp2"]

  }
}

