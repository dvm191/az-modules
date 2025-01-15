# Configure Terraform to set the required AzureRM provider
# version and features{} block.

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.46.0"
    }
  }
  # backend "azurerm" {}
}


provider "azurerm" {
  #storage_use_azuread = true
  features {}
}

provider "azuread" {
  #storage_use_azuread = true
}