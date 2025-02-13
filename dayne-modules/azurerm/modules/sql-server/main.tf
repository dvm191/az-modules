resource "azurerm_user_assigned_identity" "admin" {
  name                = try(var.user_assigned_admin, "dbtestadmin" )
  location            = var.location
  resource_group_name = var.resource_group_name

}

data azurerm_client_config "current" {}

resource "azurerm_mssql_server" "sql" {
  name                         = try(var.sql_name, "example-resource" )
  resource_group_name          = var.resource_group_name
  location                     = var.location
  version                      = var.sql_server_version
  administrator_login          = try(var.administrator_login, "exampleadmin")
  administrator_login_password = try(var.administrator_login_password, "Password123!")
  minimum_tls_version          = try(var.min_tls_version, "1.2")

  azuread_administrator {
    login_username = azurerm_user_assigned_identity.admin.name
    object_id      = azurerm_user_assigned_identity.admin.principal_id
  }

  identity {
    type         = try(var.identity_type, "UserAssigned")
    identity_ids = [azurerm_user_assigned_identity.admin.id]
  }

  primary_user_assigned_identity_id            = azurerm_user_assigned_identity.admin.id
  # transparent_data_encryption_key_vault_key_id = azurerm_key_vault_key.example.id
}

# Create a key vault with access policies which allow for the current user to get, list, create, delete, update, recover, purge and getRotationPolicy for the key vault key and also add a key vault access policy for the Microsoft Sql Server instance User Managed Identity to get, wrap, and unwrap key(s)
resource "azurerm_key_vault" "kv" {
  name                        = try(var.kv_name, "mssqltdeexample")
  location                    = var.location
  resource_group_name         = var.resource_group_name
  enabled_for_disk_encryption = try(var.enabled_for_disk_encryption, true)
  tenant_id                   = azurerm_user_assigned_identity.admin.tenant_id
  soft_delete_retention_days  = try(var.soft_delete_retention_days, 90)
  purge_protection_enabled    = try(var.purge_protection_enabled, true)

  sku_name = try(var.sku_name, "standard")

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = ["Get", "List", "Create", "Delete", "Update", "Recover", "Purge", "GetRotationPolicy"]
  }

  access_policy {
    tenant_id = azurerm_user_assigned_identity.admin.tenant_id
    object_id = azurerm_user_assigned_identity.admin.principal_id

    key_permissions = ["Get", "WrapKey", "UnwrapKey"]
  }
}

resource "azurerm_key_vault_key" "example" {
  depends_on = [azurerm_key_vault.kv]

  name         = "example-key"
  key_vault_id = azurerm_key_vault.kv.id
  key_type     = "RSA"
  key_size     = 2048

  key_opts = ["unwrapKey", "wrapKey"]
}

resource "azurerm_mssql_elasticpool" "example" {
  name                = var.elastic_pool_name
  resource_group_name = var.resource_group_name
  location            = var.location
  server_name         = azurerm_mssql_server.sql.name

  sku {
    name     = var.elastic_pool_sku_name
    tier     = try(var.elastic_pool_sku_tier, "Standard")
    capacity = var.elastic_pool_dtu
  }

  per_database_settings {
    min_capacity = var.elastic_pool_db_dtu_min
    max_capacity = var.elastic_pool_db_dtu_max
  }

  max_size_gb = var.elastic_pool_max_size_gb
}