# Create Resource Group

data "azurerm_resource_group" "rg_c8000v" {
  name = var.rg
}
