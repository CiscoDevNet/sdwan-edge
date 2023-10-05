/*
  VPC
*/
resource "aws_vpc" "instance" {
  cidr_block           = var.address_space
  enable_dns_hostnames = true

  tags = merge(
    var.common_tags,
    {
      Name = var.name
    }
  )
}
