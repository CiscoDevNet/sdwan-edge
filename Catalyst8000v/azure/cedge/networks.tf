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

resource "azurerm_route_table" "service" {
  name                          = "${var.subnet_service}-rt"
  location                      = data.azurerm_resource_group.rg_c8000v.location
  resource_group_name           = data.azurerm_resource_group.rg_c8000v.name
  disable_bgp_route_propagation = false

  route {
    name                   = "cloud"
    address_prefix         = "10.128.0.0/16"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = azurerm_network_interface.service.private_ip_address
  }

  route {
    name                   = "dc"
    address_prefix         = "22.0.0.0/8"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = azurerm_network_interface.service.private_ip_address
  }

  tags = {
    environment = "Production"
  }
}

resource "azurerm_subnet_route_table_association" "service" {
  subnet_id      = data.azurerm_subnet.service_subnet.id
  route_table_id = azurerm_route_table.service.id
}
