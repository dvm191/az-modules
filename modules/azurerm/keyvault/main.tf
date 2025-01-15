provider "azurerm" {
  features {}
}

resource "azurerm_key_vault" "keyvault" {
  name                        = var.name
  location                    = var.location
  resource_group_name         = var.resource_group_name
  tenant_id                   = var.tenant_id
  sku_name                    = var.sku_name

  soft_delete_enabled         = true
  purge_protection_enabled    = false

  tags                        = var.tags
}

output "key_vault_id" {
  value = azurerm_key_vault.keyvault.id
}
