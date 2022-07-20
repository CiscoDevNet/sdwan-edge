/*
  VPC
*/
resource "aws_vpc" "instance" {
  cidr_block           = var.address_space
  enable_dns_hostnames = true

  tags = {
    Name = var.name
  }
}
