output "cedge_id" {
  value = azurerm_virtual_machine.c8000v.id
}

output "cedge_public_ip" {
    value = azurerm_public_ip.public.ip_address
}

output "cedge_transport_ip" {
    value = azurerm_network_interface.transport.private_ip_address
}

output "cedge_service_ip" {
    value = azurerm_network_interface.service.private_ip_address
}

