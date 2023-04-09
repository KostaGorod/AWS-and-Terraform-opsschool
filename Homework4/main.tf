module "vpc_module" {
  source         = "./modules/vpc"
  vpc_cidr_block = "10.0.0.0/16"
  # private_subnets_cidr_list = ["10.0.2.0/24", "10.0.3.0/24"]
  # public_subnets_cidr_list  = ["10.0.100.0/24", "10.0.101.0/24"]
  env_name    = "whiskey_app"
  common_tags = { Env = "stg", Owner = "kosta" }
}




# resource "aws_instance" "db" {
#   count                  = var.db_instances_count
#   ami                    = data.aws_ami.amazon-linux-2.id
#   instance_type          = "t3.micro"
#   subnet_id              = module.vpc_module.private_subnets[count.index % module.vpc.private_subnet_count]
#   vpc_security_group_ids = [aws_security_group.db_sg.id]
#   availability_zone      = data.aws_availability_zones.available.names[count.index % 2]
#   key_name               = var.key_name
#   root_block_device {
#     volume_size           = "10"
#     volume_type           = "gp2"
#     encrypted             = false
#     delete_on_termination = true
#   }

#   user_data = <<EOF
#   #!/bin/bash
#   cd ~
#   echo "this is a db server${count.index}" >> db.txt
# EOF 
#   tags = {
#     Name    = "db-${count.index}"
#     Owner   = "Kosta"
#     Purpose = "db"
#   }
# }

// TODO finish DB servers
resource "aws_instance" "db_server" {
  count         = var.db_instances_count
  ami           = data.aws_ami.ubuntu-22.id
  instance_type = var.db_instance_type
  subnet_id     = element(module.vpc_module.private_subnets_id[*], count.index)
  # subnet_id              = module.vpc_module.private_subnets[count.index % module.vpc.private_subnet_count]
  # availability_zone      = data.aws_availability_zones.available.names[count.index % 2]
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.db.id]
  iam_instance_profile   = "ec2-ssm-access-rule"
  root_block_device {
    volume_size           = "10"
    volume_type           = "gp2"
    encrypted             = false
    delete_on_termination = true
  }
  user_data = templatefile("ec2-db-init-script.tftpl", { instance_num = "${count.index}", vpc_cidr = "${module.vpc_module.vpc_cidr_block}" })
  tags = {
    Name    = "db-${count.index}"
    Owner   = "Kosta"
    Purpose = "whiskey"
  }
}


