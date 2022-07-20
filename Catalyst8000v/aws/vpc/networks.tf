/*
  Subnets
*/
resource "aws_subnet" "subnet_transport" {
  vpc_id            = aws_vpc.instance.id
  cidr_block        = var.subnet_transport_prefix
  availability_zone = var.availability_zone

  tags = {
    Name = "${var.subnet_name_prefix}-transport"
  }
}

resource "aws_subnet" "subnet_service" {
  vpc_id            = aws_vpc.instance.id
  cidr_block        = var.subnet_service_prefix
  availability_zone = var.availability_zone

  tags = {
    Name = "${var.subnet_name_prefix}-service"
  }
}

/*
  Gateways
*/
resource "aws_internet_gateway" "instance" {
  vpc_id = aws_vpc.instance.id

  tags = {
    Name = "${var.name}-igw"
  }
}

resource "aws_eip" "nat" {
   vpc   = true

  tags = {
    Name = "${var.name}-natgw"
  }

}

resource "aws_nat_gateway" "instance" {
  allocation_id = aws_eip.nat.id
  subnet_id = aws_subnet.subnet_transport.id
}

/*
  Route tables
*/
resource "aws_route_table" "transport" {
  vpc_id = aws_vpc.instance.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.instance.id
  }

  tags = {
    Name = "${var.name}-rt-transport"
  }
}
resource "aws_route_table" "service" {
  vpc_id = aws_vpc.instance.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.instance.id
  }

  tags = {
    Name = "${var.name}-rt-service"
  }
}

/*
  Route table associations
*/
resource "aws_route_table_association" "transport" {
  subnet_id      = aws_subnet.subnet_transport.id
  route_table_id = aws_route_table.transport.id
}
resource "aws_route_table_association" "service" {
  subnet_id      = aws_subnet.subnet_service.id
  route_table_id = aws_route_table.service.id
}
