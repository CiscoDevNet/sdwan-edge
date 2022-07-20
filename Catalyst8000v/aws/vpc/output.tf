output "vpc_id" {
  value = aws_vpc.instance.id
}

output "subnet_transport" {
  value = aws_subnet.subnet_transport.id
}

output "subnet_service" {
  value = aws_subnet.subnet_service.id
}
