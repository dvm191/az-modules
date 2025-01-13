# Create public IPs
resource "azurerm_public_ip" "my_terraform_public_ip" {
  name                = "dev-infra-agw-pip-testing"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# Create public IP for the network interface
resource "azurerm_public_ip" "nic_public_ip" {
  name                = "dev-test-nic-pip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}