// getting the available AZs
data "aws_availability_zones" "available" {
  state = "available"
}

# TODO ADD name
// Creating the VPC
resource "aws_vpc" "whiskey" {
  cidr_block = "10.0.0.0/16"
}

// Creating igw
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.whiskey.id

  tags = {
    "Name" = "Whiskey igw"
  }
}
#TODO use different AZs
// Creating 2 Public Subnets on 2 AZs
resource "aws_subnet" "public" {
  count             = 2
  vpc_id            = aws_vpc.whiskey.id
  availability_zone = data.aws_availability_zones.available.names[count.index]
  cidr_block        = cidrsubnet(aws_vpc.whiskey.cidr_block, 8, count.index)

  tags = {
    Name = "Whiskey_Public-${count.index}"
  }
}

#TODO use different AZs
// Creating 2 Private Subnets on 2 AZs
resource "aws_subnet" "private" {
  count             = 2
  vpc_id            = aws_vpc.whiskey.id
  availability_zone = data.aws_availability_zones.available.names[count.index]
  cidr_block        = cidrsubnet(aws_vpc.whiskey.cidr_block, 8, (length(aws_subnet.public) + count.index))

  tags = {
    Name = "Whiskey_Private-${count.index}"
  }
}


// Requesting 2 Elastic IPs, 1 for each AZ
resource "aws_eip" "nat" {
  vpc = true

  tags = {
    Name = "Whiskey_eip_NAT"
  }
}


// Creating 2 NAT GW, deployed on Public SBs
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id

  tags = {
    Name = "Whiskey_NATGW"
  }
}


// Creating 2 Private RT for NAT GWs
resource "aws_route_table" "private" {
  count  = 2
  vpc_id = aws_vpc.whiskey.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat.id
  }

  tags = {
    Name = "Whiskey_PrivateRT-${count.index}"
  }
}

// Creating Public RT
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.whiskey.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "Whiskey_PublicRT"
  }
}

// Associating the SBs with the RTs
resource "aws_route_table_association" "private" {
  count          = 2
  subnet_id      = element(aws_subnet.private[*].id,count.index)
  route_table_id = element(aws_route_table.private[*].id,count.index)
}
resource "aws_route_table_association" "public" {
  count          = 2
  subnet_id      = element(aws_subnet.public[*].id,count.index)
  route_table_id = aws_route_table.public.id
}

// Creating SG for ALB use for HTTP access
resource "aws_security_group" "front_end" {
  name        = "allow_http"
  description = "allow HTTP outbound traffic"
  vpc_id      = aws_vpc.whiskey.id

  # Inbound HTTP
  ingress {
    description      = "allow HTTP from internet"
    protocol         = "tcp"
    from_port        = 80
    to_port          = 80
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  # outbound
  egress {
    description      = "allow outbound traffic"
    protocol         = "-1"
    from_port        = 0
    to_port          = 0
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}


// Crating Target Group for Public access
resource "aws_lb_target_group" "front_end" {
  name     = "front-end-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.whiskey.id

  load_balancing_algorithm_type = "round_robin"

  health_check {
    enabled             = true
    port                = 80
    interval            = 10
    protocol            = "HTTP"
    path                = "/"
    matcher             = "200"
    healthy_threshold   = 5
    unhealthy_threshold = 3
  }
}

// Attaching webservers to Target Group
resource "aws_lb_target_group_attachment" "front_end" {
  count            = 2
  target_group_arn = aws_lb_target_group.front_end.arn
  target_id        = element(aws_instance.webserver[*].id,count.index)
  port             = 80
}

// Creating the Application LB
resource "aws_lb" "front_end" {
  name               = "webserver-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.front_end.id]

  subnets = [for subnet in aws_subnet.public : subnet.id] #TODO make elastic
}

// Creating LB listiner and forwarding it to the ALB
resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.front_end.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.front_end.arn
  }
}