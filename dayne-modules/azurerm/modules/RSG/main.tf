locals {
  resource_group_name = var.resource_group_name
  location            = var.location
}


resource "azurerm_resource_group" "rg" {
  name     = local.resource_group_name
  location = local.location
}