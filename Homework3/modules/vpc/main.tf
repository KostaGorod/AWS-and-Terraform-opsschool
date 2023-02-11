
# Creating the VPC

resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr_block

  tags = merge(var.common_tags, {
    "Name" = "${var.env_name}-vpc"
  })
}

# Internet gateway

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = merge(var.common_tags, {
    "Name" = "${var.env_name}-vpc-gateway"
  })
}

# Elastic IP for NAT GW (for private network connectivity)

resource "aws_eip" "nat_eip" {
  vpc = true

  tags = merge(var.common_tags,{
    Name = "${var.env_name}-nat-eip"
  })
}

resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_subnet[0].id

  tags = merge(var.common_tags,{
    Name = "${var.env_name}-NAT-GW"
  })
}


# getting the available AZs
data "aws_availability_zones" "available" {
  state = "available"
}

##############################
########### Public ###########
##############################
resource "aws_subnet" "public_subnet" {
  map_public_ip_on_launch = true
  count                   = 2
  cidr_block              = cidrsubnet(var.vpc_cidr_block, 8, count.index)
  vpc_id                  = aws_vpc.main.id
  availability_zone       = data.aws_availability_zones.available.zone_ids[count.index]

  tags = merge(var.common_tags,{
    Name = "${var.env_name}-public_subnet-${count.index}"
  })
}


resource "aws_route_table" "public_route" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = merge(var.common_tags,{
    Name = "${var.env_name}-public_route_table"
  })
}
# Associating the Subnets with the route table
resource "aws_route_table_association" "public_route_association" {
  count          = 2
  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.public_route.id
}


##############################
########### Private ##########
##############################

resource "aws_subnet" "private_subnet" {
  map_public_ip_on_launch = false
  count                   = 2
  cidr_block              = cidrsubnet(var.vpc_cidr_block, 8, 100+count.index)
  vpc_id                  = aws_vpc.main.id
  availability_zone       = data.aws_availability_zones.available.zone_ids[count.index]

  tags = merge(var.common_tags,{
    Name = "${var.env_name}-private_subnet-${count.index}"
  })
}

resource "aws_route_table" "private_route" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = merge(var.common_tags,{
    Name = "${var.env_name}-private_route_table"
  })
}

# Associating the Subnets with the route table
resource "aws_route_table_association" "private_route_association" {
  count          = 2
  subnet_id      = aws_subnet.private_subnet[count.index].id
  route_table_id = aws_route_table.private_route.id
}


