data "aws_subnet" "subnet_transport" {
  vpc_id = data.aws_vpc.instance.id
  filter {
    name   = "tag:Name"
    values = [var.subnet_transport]
  }
}

data "aws_subnet" "subnet_service" {
  vpc_id = data.aws_vpc.instance.id
  filter {
    name	 = "tag:Name"
    values = [var.subnet_service]
  }
}
