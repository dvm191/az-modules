data "azurerm_subscription" "current" {}

locals {
  resource_group_name = var.resource_group_name
  location            = var.location
  virtual_network_name = var.vnet_name
}

resource "azurerm_subnet" "BastionSubnet" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = local.resource_group_name
  virtual_network_name = local.virtual_network_name
  address_prefixes     = var.subnet_address_prefixes
}

resource "azurerm_public_ip" "address" {
  name                = var.public_ip_name
  location            = local.location
  resource_group_name = local.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_bastion_host" "build" {
  name                = var.bastion_name
  location            = local.location
  resource_group_name = local.resource_group_name

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.BastionSubnet.id
    public_ip_address_id = azurerm_public_ip.address.id
  }
}