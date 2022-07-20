# Create subnets

resource "azurerm_subnet" "subnet_transport" {
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  name                 = "${var.subnet_name_prefix}-transport"
  address_prefixes     = [var.subnet_transport_prefix]

}

resource "azurerm_subnet" "subnet_service" {
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  name                 = "${var.subnet_name_prefix}-service"
  address_prefixes     = [var.subnet_service_prefix]
}
