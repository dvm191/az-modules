output "id" {
  value = azurerm_key_vault.kv.id
}

output "vaultUri" {
  value = azurerm_key_vault.kv.vault_uri
}

output "name" {
  value = azurerm_key_vault.kv.name
}

output "enableRbacAuthorization" {
  value = azurerm_key_vault.kv.enable_rbac_authorization
}