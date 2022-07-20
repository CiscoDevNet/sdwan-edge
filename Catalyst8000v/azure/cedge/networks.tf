data "azurerm_subnet" "transport_subnet" {
  name                 = var.subnet_transport
  virtual_network_name = var.virtual_network
  resource_group_name  = data.azurerm_resource_group.rg_c8000v.name
}

data "azurerm_subnet" "service_subnet" {
  name                 = var.subnet_service
  virtual_network_name = var.virtual_network
  resource_group_name  = data.azurerm_resource_group.rg_c8000v.name
}
