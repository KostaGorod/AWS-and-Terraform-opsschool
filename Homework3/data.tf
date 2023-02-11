

data "aws_availability_zones" "available" {
  state = "available"
}


data "aws_ami" "ubuntu-22" {
  most_recent = true
  owners      = [var.ubuntu_account_number]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}
