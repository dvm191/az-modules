# Create subnet
resource "azurerm_subnet" "dev-infra-snet-infra-testing" {
  name                 = "dev-infra-snet-infra-testing"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.my_terraform_network.name
  address_prefixes     = ["10.101.220.0/27"]
}

# Create a bastion subnet
resource "azurerm_subnet" "bastion_subnet" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.my_terraform_network.name
  address_prefixes     = ["10.101.220.32/27"]
}

