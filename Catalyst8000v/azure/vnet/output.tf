output "resource_group" {
  value = azurerm_resource_group.rg.id
}

output "vnet_id" {
  value = azurerm_virtual_network.vnet.name
}

output "subnet_transport" {
  value = azurerm_subnet.subnet_transport.id
}

output "subnet_service" {
  value = azurerm_subnet.subnet_service.id
}

