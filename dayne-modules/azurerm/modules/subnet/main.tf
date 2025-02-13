resource "azurerm_subnet" "subnet" {
  name                 = try(var.subnet_name, "frontend")
  resource_group_name  = try(var.resource_group_name, "myResourceGroup")
  virtual_network_name = var.vnet_name
  address_prefixes     = var.subnet_address_prefixes
}

resource "azurerm_network_security_group" "nsg" {
  name                = try(var.nsg_name, "frontend-nsg")
  location            = try(var.location, "eastus")
  resource_group_name = var.resource_group_name

  security_rule {
    name                       = try(var.security_rule, "Deny-All-Inbound")
    priority                   = 4000
    direction                  = try(var.direction, "Inbound" )
    access                     = try(var.access, "Deny")
    protocol                   = try(var.protocol,"*")
    source_port_range          = try(var.source_port_range, "*")
    destination_port_range     = try(var.destination_port_range, "*")
    source_address_prefix      = try(var.source_address_prefix, "*")
    destination_address_prefix = try(var.destination_address_prefix, "*")
  }
}

resource "azurerm_subnet_network_security_group_association" "association" {
  subnet_id                 = azurerm_subnet.subnet.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}