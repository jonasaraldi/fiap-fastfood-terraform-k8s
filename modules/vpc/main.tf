resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name      = "${var.prefix}-vpc"
    org       = var.org
    app       = var.app
    env       = var.env
    terraform = true
  }
}

data "aws_availability_zones" "available" {}

resource "aws_subnet" "vpc-public-subnets" {
  count                   = var.subnet_count
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.${count.index}.0/24"
  map_public_ip_on_launch = true
  tags = {
    Name      = "${var.prefix}-public-subnet-${count.index}"
    org       = var.org
    app       = var.app
    env       = var.env
    terraform = true
  }
}

resource "aws_subnet" "vpc-private-subnets" {
  count             = var.subnet_count
  availability_zone = data.aws_availability_zones.available.names[count.index]
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.${count.index + var.subnet_count}.0/24"
  tags = {
    Name      = "${var.prefix}-private-subnet-${count.index}"
    org       = var.org
    app       = var.app
    env       = var.env
    terraform = true
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name      = "${var.prefix}-igw"
    org       = var.org
    app       = var.app
    env       = var.env
    terraform = true
  }
}

resource "aws_nat_gateway" "private-nat" {
  subnet_id = aws_subnet.vpc-public-subnets.*.id[0]
}

resource "aws_route_table" "private-rtb" {
  count  = var.subnet_count
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.private-nat.id
  }

  tags = {
    Name      = "private-rtb-${data.aws_availability_zones.available.names[count.index]}"
    org       = var.org
    app       = var.app
    env       = var.env
    terraform = true
  }
}

resource "aws_route" "nat-gateway-route" {
  count                  = var.subnet_count
  route_table_id         = aws_route_table.private-rtb.*.id[count.index]
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.private-nat.id
}

resource "aws_route_table_association" "private-rtb-assoc" {
  count          = var.subnet_count
  subnet_id      = aws_subnet.vpc-private-subnets.*.id[count.index]
  route_table_id = aws_route_table.private-rtb.*.id[count.index]
}

resource "aws_route_table" "public-rtb" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name      = "public-rtb"
    org       = var.org
    app       = var.app
    env       = var.env
    terraform = true
  }
}

resource "aws_route_table_association" "public-rtb-assoc" {
  count          = var.subnet_count
  subnet_id      = aws_subnet.vpc-public-subnets.*.id[count.index]
  route_table_id = aws_route_table.public-rtb.id
}
