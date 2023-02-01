
# resource "tls_private_key" "whiskey_key" {
#   algorithm = "RSA"
#   rsa_bits  = 2048
# }

# resource "aws_key_pair" "whiskey_key" {
#   key_name   = "demo"
#   public_key = tls_private_key.whiskey_key.public_key_openssh
# }
# Save the generated key pair locally
# resource "local_sensitive_file" "server_key" {
#   content  = tls_private_key.whiskey_key.private_key_pem
#   filename = "${path.module}/whiskey.pem"
# }

// TODO test SSM connection
resource "aws_instance" "webserver" {
  count                       = var.instance_count
  subnet_id                   = element(aws_subnet.private[*].id, count.index)
  ami                         = data.aws_ami.aws_linux2.id
  instance_type               = var.instance_type
  associate_public_ip_address = false
  vpc_security_group_ids      = [aws_security_group.front_end.id]
  #key_name                    = aws_key_pair.whiskey_key.key_name
  user_data_replace_on_change = true
  ebs_block_device {
    device_name = "/dev/sdf"
    volume_size = 10
    encrypted   = true
  }
  user_data = templatefile("ec2-init-script.tftpl", { instance_num = "${count.index}" })

  tags = {
    Name    = "Whiskey_webserver-${count.index}"
    Purpose = "Whiskey"
  }
}


// TODO finish DB servers
resource "aws_instance" "db_server" {
  count                  = var.instance_count
  subnet_id              = element(aws_subnet.private[*].id, count.index)
  ami                    = data.aws_ami.aws_linux2.id
  instance_type          = var.instance_type # TODO seperate from websver var
  vpc_security_group_ids = [aws_security_group.front_end.id]
  #key_name               = aws_key_pair.whiskey_key.key_name
  user_data              = file("ec2-db-init-script.tftpl")
  tags = {
    Name    = "db_server-${count.index}"
    Purpose = "Whiskey"
  }
}