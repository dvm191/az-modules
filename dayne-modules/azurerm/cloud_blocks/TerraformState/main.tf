output "storage_account_id" {
  value = module.storage_account.storage_account_id
}

output "storage_account_primary_endpoint" {
  value = module.storage_account.storage_account_primary_endpoint
}

module "storage_account" {
  source                  = "../../azurerm/storage-account"
  resource_group_name     = var.resource_group_name
  location                = var.location
  storage_account_name    = var.storage_account_name
  container_name          = var.container_name
  accountTier             = var.accountTier
  accessTier              = var.accessTier
  accountReplicationType  = var.accountReplicationType
  httpsTrafficOnlyEnabled = var.httpsTrafficOnlyEnabled
  minTlsVersion           = var.minTlsVersion
  allowNestedItemsToBePublic = var.allowNestedItemsToBePublic
  publicNetworkAccessEnabled = var.publicNetworkAccessEnabled
  infrastructureEncryptionEnabled = var.infrastructureEncryptionEnabled
  sharedAccessKeyEnabled  = var.sharedAccessKeyEnabled
  defaultToOauthAuthentication = var.defaultToOauthAuthentication
  localUserEnabled        = var.localUserEnabled
  sftpEnabled             = var.sftpEnabled
  versioningEnabled       = var.versioningEnabled
  changeFeedEnabled       = var.changeFeedEnabled
  lastAccessTimeEnabled   = var.lastAccessTimeEnabled
  bypass                  = var.bypass
  defaultAction           = var.defaultAction
  ipRules                 = var.ipRules
  virtualNetworkSubnetIds = var.virtualNetworkSubnetIds
  container_access_type   = var.container_access_type
}

resource "azurerm_storage_container" "container" {
  name                  = var.container_name
  storage_account_id    = module.storage_account.storage_account_id
  container_access_type = "private"
}





