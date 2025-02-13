resource "azurerm_mssql_database" "example" {
  name           = try(var.db_name, "test-db")
  server_id      = var.server_id
  # collation      = "SQL_Latin1_General_CP1_CI_AS"
  license_type   = try(var.license_type, "LicenseIncluded")
  max_size_gb    = try(var.max_size_gb, 10)
  read_scale     = try(var.read_scale, false)
  sku_name       = try(var.sku_name, "S0")
  zone_redundant = try(var.zone_redundant, false)
  enclave_type   = try(var.enclave_type, "VBS")

  tags = {
    environment = try(var.environment, "dev")
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [var.user_assigned_identity_id]

  }

  transparent_data_encryption_key_vault_key_id = var.key_vault_key_id

  # prevent the possibility of accidental data loss
  lifecycle {
    prevent_destroy = true
  }
}