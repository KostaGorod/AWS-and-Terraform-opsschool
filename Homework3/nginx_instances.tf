resource "tls_private_key" "whiskey_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "aws_key_pair" "whiskey_key" {
  key_name   = var.key_name
  public_key = tls_private_key.whiskey_key.public_key_openssh
}
# Save the generated key pair locally
resource "local_sensitive_file" "server_key" {
  content  = tls_private_key.whiskey_key.private_key_pem
  filename = "${path.module}/${var.key_name}"
}


# INSTANCES
resource "aws_instance" "nginx" {
  count                       = var.nginx_instances_count
  ami                         = data.aws_ami.ubuntu-22.id
  instance_type               = var.instance_type
  key_name                    = var.key_name
  subnet_id                   = element(module.vpc_module.public_subnets_id, count.index)
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.nginx_instances_access.id]
  user_data                   = templatefile("ec2-init-script.tftpl", { instance_num = "${count.index}", vpc_cidr = "${module.vpc_module.vpc_cidr_block}" })
  iam_instance_profile        = aws_iam_instance_profile.nginx_instances.name

  #   root_block_device {
  #     encrypted   = false
  #     volume_type = var.volumes_type
  #     volume_size = var.nginx_root_disk_size
  #   }

  #   ebs_block_device {
  #     encrypted   = true
  #     device_name = var.nginx_encrypted_disk_device_name
  #     volume_type = var.volumes_type
  #     volume_size = var.nginx_encrypted_disk_size
  #   }

  tags = {
    # Name    = "nginx-web-${regex(".$", data.aws_availability_zones.available.names[count.index])}" # Inconsistent when expanding
    Name    = "nginx-web-${count.index}"
    Owner   = "Kosta"
    Purpose = "whiskey"
  }
}
##################


resource "aws_security_group" "nginx_instances_access" {
  vpc_id = module.vpc_module.vpc_id
  name   = "nginx-access"

  tags = {
    Name = "nginx-access-${module.vpc_module.vpc_id}"
  }
}

resource "aws_security_group_rule" "nginx_http_acess" {
  description       = "allow http access from anywhere"
  from_port         = 80
  protocol          = "tcp"
  security_group_id = aws_security_group.nginx_instances_access.id
  to_port           = 80
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "nginx_ssh_acess" {
  description       = "allow ssh access from anywhere"
  from_port         = 22
  protocol          = "tcp"
  security_group_id = aws_security_group.nginx_instances_access.id
  to_port           = 22
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "nginx_outbound_anywhere" {
  description       = "allow outbound traffic to anywhere"
  from_port         = 0
  protocol          = "-1"
  security_group_id = aws_security_group.nginx_instances_access.id
  to_port           = 0
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
}
