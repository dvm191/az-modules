resource "azurerm_subnet" "BastionSubnet" {
  name                 = try(var.bastion_subnet_name, "AzureBastionSubnet")
  resource_group_name  = var.resource_group_name
  virtual_network_name = var.vnet_name
  address_prefixes     = var.subnet_address_prefixes
}

resource "azurerm_public_ip" "address" {
  name                = var.public_ip_name
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = try(var.allocation_method, "Static")
  sku                 = try(var.sku, "Standard")
}

resource "azurerm_bastion_host" "build" {
  name                = try(var.bastion_name, "Bastion")
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.BastionSubnet.id
    public_ip_address_id = azurerm_public_ip.address.id
  }
}