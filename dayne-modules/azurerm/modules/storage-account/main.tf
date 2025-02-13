resource "azurerm_storage_account" "storage" {
  name                      = var.storage_account_name
  resource_group_name       = var.resource_group_name
  location                  = var.location
  account_tier              = try(var.accountTier, "Standard")
  access_tier               = try(var.accessTier, "Hot")
  account_replication_type  = try(var.accountReplicationType, "LRS")
  https_traffic_only_enabled        = try(var.httpsTrafficOnlyEnabled, true)
  min_tls_version                   = try(var.minTlsVersion, "TLS1_2")
  allow_nested_items_to_be_public   = try(var.allowNestedItemsToBePublic, false)
  public_network_access_enabled     = try(var.publicNetworkAccessEnabled, true)
  infrastructure_encryption_enabled = try(var.infrastructureEncryptionEnabled, true)
  shared_access_key_enabled         = try(var.sharedAccessKeyEnabled, true)
  default_to_oauth_authentication   = try(var.defaultToOauthAuthentication, false)
  local_user_enabled                = try(var.localUserEnabled, true)
  sftp_enabled                      = try(var.sftpEnabled, false)

  blob_properties {
    versioning_enabled       = try(var.versioningEnabled, false)
    change_feed_enabled      = try(var.changeFeedEnabled, false)
    last_access_time_enabled = try(var.lastAccessTimeEnabled, false)

    delete_retention_policy {
      days = 7
    }

    container_delete_retention_policy {
      days = 7
    }
  }

  network_rules {
    bypass                     = try(var.bypass, ["None"])
    default_action             = try(var.defaultAction, "Deny")
    ip_rules                   = try(var.ipRules, [])
    virtual_network_subnet_ids = try(var.virtualNetworkSubnetIds, [])
  }

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_storage_container" "container" {
  name                  = var.container_name
  storage_account_id    = azurerm_storage_account.storage.id
  container_access_type = try(var.container_access_type,"private")
}