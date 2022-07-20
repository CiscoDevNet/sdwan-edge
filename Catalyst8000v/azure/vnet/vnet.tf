# Create a VNET

resource "azurerm_virtual_network" "vnet" {
  resource_group_name = azurerm_resource_group.rg.name
  name                = var.name
  address_space       = [var.address_space]
  location            = var.region
}

