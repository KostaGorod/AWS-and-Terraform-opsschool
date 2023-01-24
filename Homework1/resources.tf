

  # HTTP access from anywhere
resource "aws_security_group" "allow_http" {
  name = "allow_http"

  ingress {
    from_port        = 80
    to_port          = 80
    protocol         = "TCP"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "app_server" {
  count                       = var.instance_count
  ami                         = var.instance_aws_ami
  instance_type               = var.instance_type
  security_groups             = [aws_security_group.allow_http.name] #can't be declared by id
  user_data_replace_on_change = true
  ebs_block_device {
    device_name = "/dev/sdf"
    volume_size = 10
    encrypted   = true
  }
  user_data = file("ec2-init-script.sh")

  tags = {
    Name    = "Whiskey_website-${count.index}"
    Owner   = "Kosta"
    Purpose = "Whiskey"
  }
}