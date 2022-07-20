output "cedge_id" {
  value = aws_instance.cedge.id
}

output "cedge_transport_ip" {
    value = tolist(aws_network_interface.transport.private_ips)[0]
}

output "cedge_service_ip" {
    value = tolist(aws_network_interface.service.private_ips)[0]
}

output "cedge_transport_public_ip" {
    value = aws_eip.cedge_eip.public_ip
}
