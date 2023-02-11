## VPC

# getting the available AZs
data "aws_availability_zones" "available" {
  state = "available"
}


# Creating the VPC

resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr_block

  tags = {
    "Name" = "${var.APP_NAME}-vpc-${var.ENV}"
  }
}

# Subnets

resource "aws_subnet" "public" {
  map_public_ip_on_launch = true
  count                   = length(var.public_subnets_cidr_list)
  cidr_block              = var.public_subnets_cidr_list[count.index]
  vpc_id                  = aws_vpc.vpc.id
  availability_zone       = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "public-subnet-${var.APP_NAME}-${count.index}-${var.ENV}"
  }
}

# Creating 2 Private Subnets on 2 AZs

resource "aws_subnet" "private" {
  map_public_ip_on_launch = false
  count                   = length(var.private_subnets_cidr_list)
  cidr_block              = var.private_subnets_cidr_list[count.index]
  vpc_id                  = aws_vpc.vpc.id
  availability_zone       = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "private-subnet-${var.APP_NAME}-${count.index}-${var.ENV}"
  }
}


# Internet gateway

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    "Name" = "${var.APP_NAME}-vpc-gateway-${var.ENV}"
  }
}


# Creating Public RT
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${var.APP_NAME}-public-route-table-${var.ENV}"
  }
}

resource "aws_route_table" "private" {
  #count  = 2
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat.id
  }

  tags = {
    Name = "${var.APP_NAME}-private-route-table-${var.ENV}"
  }
}


# Associating the SBs with the RTs

resource "aws_route_table_association" "private" {
  count          = 2
  subnet_id      = element(aws_subnet.private[*].id, count.index)
  route_table_id = element(aws_route_table.private[*].id, count.index)
  # for_each       = aws_subnet.private
  # subnet_id      = each.value.id
  # route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "public" {
  count          = 2
  subnet_id      = element(aws_subnet.public[*].id, count.index)
  route_table_id = aws_route_table.public.id
  # for_each       = aws_subnet.public
  # subnet_id      = each.value.id
  # route_table_id = aws_route_table.public.id
}




# Elastic IP for NAT GW (for private network connectivity)

resource "aws_eip" "nat" {
  vpc = true

  tags = {
    Name = "${var.APP_NAME}-NAT-EIP-${var.ENV}"
  }
}


#

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id

  tags = {
    Name = "${var.APP_NAME}-NAT-GW-${var.ENV}"
  }
}


# Creating SG for ALB use for HTTP access

# TODO: seperate rules into aws_security_group_rule 
# http://cavaliercoder.com/blog/inline-vs-discrete-security-groups-in-terraform.html
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule

# resource "aws_security_group_rule" "ingress_public" {
#   for_each          = var.ingress_tcp_ports_public_subnets
#   type              = "ingress"
#   protocol          = "tcp"
#   cidr_blocks       = ["0.0.0.0/0"]
#   from_port         = each.value
#   to_port           = each.value
#   security_group_id = aws_security_group.front_end.id
# }

# resource "aws_security_group" "front_end" {
#   name        = "public_allow_http"
#   description = "allow HTTP outbound traffic"
#   vpc_id      = aws_vpc.vpc.id

# Inbound HTTP

# ingress {
#   description      = "allow HTTP from internet to public subnets"
#   protocol         = "tcp"
#   from_port        = 80
#   to_port          = 80
#   cidr_blocks      = ["0.0.0.0/0"]
#   ipv6_cidr_blocks = ["::/0"]
# }

# outbound

#   egress {
#     description      = "allow outbound traffic"
#     protocol         = "-1"
#     from_port        = 0
#     to_port          = 0
#     cidr_blocks      = ["0.0.0.0/0"]
#     ipv6_cidr_blocks = ["::/0"]
#   }
# }


# Crating Target Group for Public access

# resource "aws_lb_target_group" "front_end" {
#   name     = "front-end-tg"
#   port     = 80
#   protocol = "HTTP"
#   vpc_id   = aws_vpc.vpc.id

#   load_balancing_algorithm_type = "round_robin"

#   health_check {
#     enabled             = true
#     port                = 80
#     interval            = 10
#     protocol            = "HTTP"
#     path                = "/"
#     matcher             = "200"
#     healthy_threshold   = 5
#     unhealthy_threshold = 3
#   }
# }

# # Attaching webservers to Target Group

# resource "aws_lb_target_group_attachment" "front_end" {
#   count            = 2
#   target_group_arn = aws_lb_target_group.front_end.arn
#   target_id        = element(aws_instance.webserver[*].id, count.index)
#   port             = 80
# }

# # Creating the Application LB

# resource "aws_lb" "front_end" {
#   name               = "webserver-lb"
#   internal           = false
#   load_balancer_type = "application"
#   security_groups    = [aws_security_group.front_end.id]

#   subnets = [for subnet in aws_subnet.public : subnet.id] #TODO make elastic
# }

# # Creating LB listiner and forwarding it to the ALB

# resource "aws_lb_listener" "front_end" {
#   load_balancer_arn = aws_lb.front_end.arn
#   port              = 80
#   protocol          = "HTTP"

#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.front_end.arn
#   }
# }
