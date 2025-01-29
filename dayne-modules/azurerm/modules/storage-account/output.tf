output "storage_account_id" {
  description = "The ID of the storage account."
  value       = azurerm_storage_account.storageacc.id
}

output "storage_account_primary_endpoint" {
  description = "The primary endpoint of the storage account."
  value       = azurerm_storage_account.storageacc.primary_blob_endpoint
}