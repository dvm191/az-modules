resource "azurerm_bastion_host" "example" {
  name                = "dev-test-bastion"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

#   dns_name            = "dev-test-bastion"
  sku                 = "Basic"

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.bastion_subnet.id
    public_ip_address_id = azurerm_public_ip.my_terraform_public_ip.id
  }
}