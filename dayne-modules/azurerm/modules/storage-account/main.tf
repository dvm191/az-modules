resource "azurerm_storage_account" "storage" {
  name                      = var.storage_account_name
  resource_group_name       = var.resource_group_name
  location                  = var.location
  account_tier              = var.accountTier
  access_tier               = var.accessTier
  account_replication_type  = var.accountReplicationType
  https_traffic_only_enabled        = true
  min_tls_version                   = "TLS1_2"
  allow_nested_items_to_be_public   = false
  public_network_access_enabled     = false
  infrastructure_encryption_enabled = true
  shared_access_key_enabled         = true
  default_to_oauth_authentication   = false
  local_user_enabled                = true
  sftp_enabled                      = false

  blob_properties {
    versioning_enabled       = false
    change_feed_enabled      = false
    last_access_time_enabled = false

    delete_retention_policy {
      days = 7
    }

    container_delete_retention_policy {
      days = 7
    }
  }

  network_rules {
    bypass                     = var.bypass
    default_action             = "Deny"
    ip_rules                   = var.ipRules
    virtual_network_subnet_ids = var.virtualNetworkSubnetIds
  }

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_storage_container" "container" {
  name                  = var.container_name
  storage_account_id    = azurerm_storage_account.storage.id
  container_access_type = "private"
}
