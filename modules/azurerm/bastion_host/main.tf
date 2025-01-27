resource "azurerm_subnet" "bast" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = var.virtual_network_name
  address_prefixes     = var.subnet_address_space
}

resource "azurerm_public_ip" "bast" {
  name                = "${var.bastion_host_name}-pip"
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Basic"
  sku_tier            = "Regional"
}

resource "azurerm_bastion_host" "bast" {
  name                   = var.bastion_host_name
  location               = var.location
  resource_group_name    = var.resource_group_name
  copy_paste_enabled     = false
  file_copy_enabled      = false
  sku                    = "Basic"
  ip_connect_enabled     = false
  scale_units            = 2
  shareable_link_enabled = false
  tunneling_enabled      = false

  ip_configuration {
    name                 = "${ar.bastion_host_name}-ipconfig"
    subnet_id            = azurerm_subnet.bast.id
    public_ip_address_id = azurerm_public_ip.bast.id
  } 
}
