provider "azurerm" {
  features {}
  subscription_id = "305c4093-10e2-4947-9901-d9e20a156857"
}

module "azure_vnet" {
  source              = "./modules/azure-vnet"
  resource_group_name = "dev-test-rg"
  location            = "East US"
  vnet_name           = "RTLSU-VirtualNetwork-testing"
  address_space       = ["10.101.220.0/23"]
  subnets = [
    {
      name           = "subnet1"
      address_prefix = "10.101.221.224/29"
    },
    {
      name           = "AzureBastionSubnet"
      address_prefix = "10.101.221.232/29"
    }
  ]
}








