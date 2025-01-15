output "id" {
  value = azurerm_storage_account.sa.id
}

output "name" {
  value = azurerm_storage_account.sa.name
}

output "primaryAccessKey" {
  value = azurerm_storage_account.sa.primary_access_key
}

output "primaryBlobEndpoint" {
  value = azurerm_storage_account.sa.primary_blob_endpoint
}

output "primaryConnectionString" {
  value = azurerm_storage_account.sa.primary_connection_string
}

output "primaryQueueEndpoint" {
  value = azurerm_storage_account.sa.primary_queue_endpoint
}

output "primaryTableEndpoint" {
  value = azurerm_storage_account.sa.primary_table_endpoint
}

output "secondaryConnectionString" {
  value = azurerm_storage_account.sa.secondary_connection_string
}

output "primaryBlobConnectionString" {
  value = azurerm_storage_account.sa.primary_blob_connection_string
}

output "container" {
  value = azurerm_storage_container.container
}