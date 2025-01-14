module "public_ip" {
  source              = "./modules/azure-pubip"
  name                = "dev-test-nin-pip"
  location            = "East US"
  resource_group_name = "dev-test-rg"
  allocation_method   = "Static"
  sku                 = "Standard"
}
