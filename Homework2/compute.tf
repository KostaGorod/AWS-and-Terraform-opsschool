resource "aws_instance" "webserver" {
  count                       = var.instance_count
  subnet_id                   = aws_subnet.public[count.index].id
  ami                         = data.aws_ami.aws_linux2.id
  instance_type               = var.instance_type
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.front_end.id]
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
  subnet_id              = aws_subnet.private[count.index].id
  ami                    = data.aws_ami.aws_linux2.id
  instance_type          = var.instance_type # TODO change to different var
  vpc_security_group_ids = [aws_security_group.front_end.id]

  tags = {
    Name    = "db_server-${count.index}"
    Purpose = "Whiskey"
  }
}