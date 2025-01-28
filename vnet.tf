provider "azurerm" {
  features {}
  subscription_id = "305c4093-10e2-4947-9901-d9e20a156857"
}

module "resource_group" {
  source              = "./modules/azurerm/RSG"
  resource_group_name = "my-resource-group"
  location            = "East US"
}



module "virtual_network" {
  source = "./modules/azurerm/virtual_network"

  virtualNetwork = {
    name              = "vnet001"
    instance          = "001"
    workload          = "example"
    values            = {
      applicationID = "app001"
      addressSpace  = ["10.101.221.224/28"]
    #   dnsServers    = ["10.0.0.4", "10.0.0.5"]
      ddosProtectionPlanEnabled = false
      encryption = {
        enforcement = "AllowUnencrypted"
      }
    }
    region            = "eus"
    complianceLevel   = "gxp"
    stage             = "dev"
    resourceGroupName = module.resource_group.resource_group_name
    tags              = {
      environment = "dev"
      project     = "example"
    }
  }
}