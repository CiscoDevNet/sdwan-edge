# Create Resource Group

resource "azurerm_resource_group" "rg" {
  name     = var.rg
  location = var.region

  tags = var.common_tags
}
