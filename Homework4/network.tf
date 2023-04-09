module "web_app_s3" {
  source = "./modules/web-app-s3"

  bucket_name             = local.s3_bucket_name
  elb_service_account_arn = data.aws_elb_service_account.root.arn
}


# SECURITY GROUPS #

# Nginx security group 
resource "aws_security_group" "nginx-sg" {
  name   = "homework2-nginx_sg"
  vpc_id = module.vpc_module.vpc_id

  tags = {
    Name  = "Nginx security group"
    Owner = "kosta"
  }
}

# HTTP access from elb

resource "aws_security_group_rule" "allow-access-elb" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = [module.vpc_module.vpc_cidr_block]
  security_group_id = aws_security_group.nginx-sg.id
}


resource "aws_security_group_rule" "allow-access-ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = [var.internet_cidr_range]
  security_group_id = aws_security_group.nginx-sg.id
}

#allow ping form vpc#
resource "aws_security_group_rule" "allow-ping-vpc" {
  type              = "ingress"
  from_port         = -1
  to_port           = -1
  protocol          = "icmp"
  cidr_blocks       = [module.vpc_module.vpc_cidr_block]
  security_group_id = aws_security_group.nginx-sg.id
}

# outbound allow all

resource "aws_security_group_rule" "allow-outbound-all" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = [var.internet_cidr_range]
  security_group_id = aws_security_group.nginx-sg.id
}

# DB security group 
resource "aws_security_group" "db" {
  name   = "db_sg"
  vpc_id = module.vpc_module.vpc_id
  tags = {
    Name  = "DB security group"
    Owner = "kosta"
  }
}

# SSH access from vpc 

resource "aws_security_group_rule" "allow-ssh-vpc" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = [var.internet_cidr_range]
  security_group_id = aws_security_group.db.id
}

#allow ping form vpc#

resource "aws_security_group_rule" "allow-ping-vpc-db" {
  type              = "ingress"
  from_port         = -1
  to_port           = -1
  protocol          = "icmp"
  cidr_blocks       = [module.vpc_module.vpc_cidr_block]
  security_group_id = aws_security_group.db.id
}

# outbound allow all
resource "aws_security_group_rule" "outbound-allow-all" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = [var.internet_cidr_range]
  security_group_id = aws_security_group.db.id
}

resource "aws_security_group" "elb-sg" {
  name   = "elb_sg"
  vpc_id = module.vpc_module.vpc_id
  tags = {
    Name  = "ELB security group"
    Owner = "kosta"
  }
}

# HTTP access from internet
resource "aws_security_group_rule" "inbound-allow-http" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = [var.internet_cidr_range]
  security_group_id = aws_security_group.elb-sg.id
}

# outbound allow all
resource "aws_security_group_rule" "outbound-allow-all-elb" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = [var.internet_cidr_range]
  security_group_id = aws_security_group.elb-sg.id
}

resource "aws_lb" "my_lb" {
  name               = "my-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.elb-sg.id]
  subnets            = [module.vpc_module.public_subnets_id[0], module.vpc_module.public_subnets_id[1]]

  enable_deletion_protection = false

  access_logs {
    bucket  = module.web_app_s3.web_bucket.id
    prefix  = "alb-logs"
    enabled = true
  }
  tags = {
    Environment = "test"
    Name        = "my-elb"
  }

}

resource "aws_lb_target_group" "my_lb" {
  name     = "alb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = module.vpc_module.vpc_id

  health_check {
    path                = "/"
    port                = 80
    healthy_threshold   = 5
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 20
    matcher             = "200"
  }

  stickiness {
    type            = "lb_cookie"
    cookie_duration = 60
    enabled         = true

  }

}

resource "aws_lb_listener" "my_lb" {
  load_balancer_arn = aws_lb.my_lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.my_lb.arn
  }

  tags = {
    Name  = "lb listener"
    Owner = "kosta"
  }
}

resource "aws_lb_target_group_attachment" "my_lb" {
  count            = var.nginx_instances_count
  target_group_arn = aws_lb_target_group.my_lb.arn
  target_id        = aws_instance.nginx[count.index].id
  port             = 80
}
