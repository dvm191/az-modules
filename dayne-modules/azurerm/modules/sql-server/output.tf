output "user_assigned_identity_id" {
  description = "The ID of the user-assigned identity."
  value       = azurerm_user_assigned_identity.admin.id
}

output "user_assigned_identity_principal_id" {
  description = "The principal ID of the user-assigned identity."
  value       = azurerm_user_assigned_identity.admin.principal_id
}

output "sql_server_id" {
  description = "The ID of the SQL Server."
  value       = azurerm_mssql_server.sql.id
}

output "sql_server_fully_qualified_domain_name" {
  description = "The fully qualified domain name of the SQL Server."
  value       = azurerm_mssql_server.sql.fully_qualified_domain_name
}

output "key_vault_id" {
  description = "The ID of the Key Vault."
  value       = azurerm_key_vault.kv.id
}

output "key_vault_uri" {
  description = "The URI of the Key Vault."
  value       = azurerm_key_vault.kv.vault_uri
}

output "key_vault_key_id" {
  description = "The ID of the Key Vault key."
  value       = azurerm_key_vault_key.example.id
}

output "key_vault_key_version" {
  description = "The version of the Key Vault key."
  value       = azurerm_key_vault_key.example.version
}

output "elastic_pool_id" {
  description = "The ID of the SQL Elastic Pool."
  value       = azurerm_mssql_elasticpool.example.id
}