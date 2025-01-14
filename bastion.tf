module "bastion" {
  source              = "./modules/azure-bastion"
  name                = "dev-test-bastion"
  location            = "East US"
  resource_group_name = "dev-test-rg"
  sku                 = "Basic"
  subnet_id           = module.azure_vnet.subnet_ids["AzureBastionSubnet"]
  public_ip_address_id = module.public_ip.ip_address_id
}