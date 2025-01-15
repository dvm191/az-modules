############################## localVariables ############################################
locals {
  storageAccount = var.storageAccount  
  location = (
    lower(local.storageAccount.region) == "eus" ?
    "EastUS" :
    lower(local.storageAccount.region) == "eus2" ?
    "EastUS2" :
    lower(local.storageAccount.region) == "gwc" ?
    "GermanyWestCentral" :
    lower(local.storageAccount.region) == "jpe" ?
    "JapanEast" :
    lower(local.storageAccount.region) == "neu" ?
    "NorthEurope" :
    lower(local.storageAccount.region) == "scus" ?
    "SouthCentralUS" :
    lower(local.storageAccount.region) == "sea" ?
    "SouthEastAsia" :
    lower(local.storageAccount.region) == "sgp" ?
    "Singapore" :
    lower(local.storageAccount.region) == "weu" ?
    "WestEurope" :
    lower(local.storageAccount.region) == "wus" ?
    "WestUS" :
    lower(local.storageAccount.region) == "wus2" ?
    "WestUS2" :
    # make it required
    ""
  )   
  storageAccountName = lower(
    format(
      "%s%s%s%s%s%s%s",
      "sa", # resourcetype
      local.storageAccount.instance,
      local.storageAccount.workload,
      local.storageAccount.values.applicationID,
      local.storageAccount.region,
      try(local.storageAccount.complianceLevel, null) == null ? "" : format("%s", local.storageAccount.complianceLevel == "gxp" ? "g" : local.storageAccount.complianceLevel == "nongxp" ? "ng" : ""), # Modification of the standard naming convention to reduce character lengths (max 24 letters) 
      local.storageAccount.stage,
    )
  )
  corsRules = try(
    flatten(
      [
        for a in local.storageAccount.values.corsRules : {
          allowedHeaders  = a.allowedHeaders
          allowedMethods  = a.allowedMethods
          allowedOrigins  = a.allowedOrigins
          exposedHeaders  = a.exposedHeaders
          maxAgeInSeconds = a.maxAgeInSeconds
        }
      ]
    ), []
  )
  privateDnsZoneGroupBlob = {
    name     = "blob"
    zoneName = "privatelink.blob.core.windows.net"      
  }
  privateDnsZoneGroupDfs = {
    name     = "dfs"
    zoneName = "privatelink.dfs.core.windows.net"      
  }
  privateDnsZoneGroupFile = {
    name     = "file"
    zoneName = "privatelink.file.core.windows.net" 
  }
  privateDnsZoneGroupQueue = {
    name    = "queue"
    zoneNam = "privatelink.queue.core.windows.net"
  }
  privateDnsZoneGroupTable = {
    name    = "table"
    zoneNam = "privatelink.queue.core.windows.net"
  }
  adGroupRole = try(
    flatten(
      [
        for adgroup, roles in local.storageAccount.values.authorization.adGroupRole : [
          for role in roles : {
            adGroupName = adgroup
            adGroupRole = role
          }
        ]
      ]
    ), []
  )
  servicePrincipalRole = try(
    flatten(
      [
        for serviceprincipal, roles in local.storageAccount.values.authorization.servicePrincipalRole : [
          for role in roles : {
            servicePrincipalName = serviceprincipal
            servicePrincipalRole = role
          }
        ]
      ]
    ), []
  )
  subnetIds = try(local.storageAccount.virtualNetworkSubnetIds, null) != null ? [for i in matchkeys(values(local.storageAccount.virtualNetworkSubnetIds), keys(local.storageAccount.virtualNetworkSubnetIds), try(local.storageAccount.values.networkRules.subnetIndex, []) ): i.id] : []
}

############################ defaultDataSources ##########################################
data "azurerm_subscription" "current" {}

data "azurerm_client_config" "current" {}

################################ Resources ###############################################
resource "azurerm_storage_account" "sa" {
  name                              = local.storageAccountName
  resource_group_name               = local.storageAccount.resourceGroupName
  location                          = local.location
  account_tier                      = try(local.storageAccount.values.accountTier, "Standard")
  account_replication_type          = try(local.storageAccount.values.accountReplicationType, "ZRS")
  access_tier                       = try(local.storageAccount.values.accessTier, "Hot")
  https_traffic_only_enabled        = try(local.storageAccount.values.httpsTrafficOnlyEnabled, true)
  min_tls_version                   = try(local.storageAccount.values.minTlsVersion, "TLS1_2")
  allow_nested_items_to_be_public   = try(local.storageAccount.values.allowNestedItemsToBePublic, false)
  is_hns_enabled                    = try(local.storageAccount.values.isHnsEnabled, false)
  cross_tenant_replication_enabled  = try(local.storageAccount.values.crossTenantReplicationEnabled, false)
  nfsv3_enabled                     = try(local.storageAccount.values.nfsv3Enabled, false)
  public_network_access_enabled     = try(local.storageAccount.values.publicNetworkAccessEnabled, true)
  infrastructure_encryption_enabled = try(local.storageAccount.values.infrastructureEncryptionEnabled, true)
  shared_access_key_enabled         = try(local.storageAccount.values.sharedAccessKeyEnabled, true)
  default_to_oauth_authentication   = try(local.storageAccount.values.defaultToOauthAuthentication, false)
  local_user_enabled                = try(local.storageAccount.values.localUserEnabled, true)
  sftp_enabled                      = try(local.storageAccount.values.sftpEnabled, false)

  blob_properties {
    versioning_enabled       = try(local.storageAccount.values.blobProperties.versioningEnabled, false)
    change_feed_enabled      = try(local.storageAccount.values.blobProperties.changeFeedEnabled, false)
    last_access_time_enabled = try(local.storageAccount.values.blobProperties.lastAccessTimeEnabled, false)

    dynamic "cors_rule" {
      for_each = try(local.storageAccount.values.blobProperties.corsRule, [])

      content {
        allowed_headers    = cors_rule.value.allowedHeaders
        allowed_methods    = cors_rule.value.allowedMethods
        allowed_origins    = cors_rule.value.allowedOrigins
        exposed_headers    = cors_rule.value.exposedHeaders
        max_age_in_seconds = cors_rule.value.maxAgeInSeconds
      }
    }

    delete_retention_policy {
      days = try(local.storageAccount.values.blobProperties.deleteRetentionPolicy.days, 7)
    }

    container_delete_retention_policy {
      days = try(local.storageAccount.values.blobProperties.containerDeleteRetentionPolicy.days, 7)
    }
  }

  network_rules {
    bypass                     = try(local.storageAccount.values.networkRules.bypass, ["None"])
    default_action             = try(local.storageAccount.values.networkRules.defaultAction, "Deny")
    ip_rules                   = try(local.storageAccount.values.networkRules.ipRules, [])
    virtual_network_subnet_ids = try(concat(try(local.storageAccount.values.networkRules.virtualNetworkSubnetIds, []), local.subnetIds), [])

    dynamic "private_link_access" {
      for_each = try(local.storageAccount.values.networkRules.privateLinkAccess, [])

      content {
        endpoint_resource_id = private_link_access.value
      }
    }
  }

  identity {
    type = try(local.storageAccount.values.identity.type, "SystemAssigned")
  }

  tags = try(local.storageAccount.tags, {})

  lifecycle {
    # Ignore changes to tags, e.g. because other services
    # updates these based on some ruleset managed elsewhere.
    # Ignore changes to customer managed key e.g. because this
    # is managed by its own resource within this module    
    ignore_changes = [tags, customer_managed_key]
  }
}

data "azuread_group" "adGroupRole" {
  for_each = {
    for x in local.adGroupRole : format("%s.%s", x.adGroupName, x.adGroupRole) => x
  }
  display_name = each.value.adGroupName
}

resource "azurerm_role_assignment" "adGroupRole" {
  for_each = {
    for x in local.adGroupRole : format("%s.%s", x.adGroupName, x.adGroupRole) => x
  }
  scope                = azurerm_storage_account.sa.id
  role_definition_name = each.value.adGroupRole
  principal_id         = data.azuread_group.adGroupRole[each.key].object_id
}

data "azuread_service_principal" "servicePrincipalRole" {
  for_each = {
    for x in local.servicePrincipalRole : format("%s.%s", x.servicePrincipalName, x.servicePrincipalRole) => x
  }
  display_name = each.value.servicePrincipalName
}

resource "azurerm_role_assignment" "servicePrincipalRole" {
  for_each = {
    for x in local.servicePrincipalRole : format("%s.%s", x.servicePrincipalName, x.servicePrincipalRole) => x
  }
  scope                = azurerm_storage_account.sa.id
  role_definition_name = each.value.servicePrincipalRole
  principal_id         = data.azuread_service_principal.servicePrincipalRole[each.key].object_id
}

resource "azurerm_private_endpoint" "privateEndpointBlob" {
  for_each            = try(toset(local.storageAccount.privateLinkSubnetId != null ? ["1"] : []), toset([])) 
  name                = lower(format("%s-%s-%s", azurerm_storage_account.sa.name, local.privateDnsZoneGroupBlob.name, "privatelink"))
  resource_group_name = local.storageAccount.resourceGroupName
  location            = local.location
  subnet_id           = local.storageAccount.privateLinkSubnetId

  private_service_connection {
    name                           = lower(format("%s-%s-%s", azurerm_storage_account.sa.name, local.privateDnsZoneGroupBlob.name, "privatelink"))
    private_connection_resource_id = azurerm_storage_account.sa.id
    is_manual_connection           = false
    subresource_names              = [local.privateDnsZoneGroupBlob.name]
  }

  private_dns_zone_group {
    name                 = local.privateDnsZoneGroupBlob.zoneName
    private_dns_zone_ids = local.storageAccount.privateDnsZoneId.blob
  }

  # dynamic "ip_configuration" {
  #   for_each = try(each.value.ipConfiguration, [])

  #   content {
  #     name               = try(ip_configuration.value.name, "private")
  #     private_ip_address = ip_configuration.value.privateIpAddress
  #     subresource_name   = try(ip_configuration.value.subresourceName, each.value.subresourceName)
  #   }
  # }
}

resource "azurerm_monitor_diagnostic_setting" "blobServices" {
  for_each                   = try(toset(local.storageAccount.logAnalyticsWorkspaceId != null ? ["blobServices"] : []), {})
  name                       = "system"
  target_resource_id         = format("%s%s", azurerm_storage_account.sa.id, "/blobServices/default")
  log_analytics_workspace_id = local.storageAccount.logAnalyticsWorkspaceId

  enabled_log {
    category = "StorageRead"
  }

  enabled_log {
    category = "StorageWrite"
  }

  enabled_log {
    category = "StorageDelete"
  }

  metric {
    category = "Capacity"
    enabled  = try(local.storageAccount.values.monitorDiagnosticSetting.blobServices.metric.capacity.enabled, true)
  }

  metric {
    category = "Transaction"
    enabled  = try(local.storageAccount.values.monitorDiagnosticSetting.blobServices.metric.transaction.enabled, false)
  }
}

resource "azurerm_monitor_diagnostic_setting" "fileServices" {
  for_each                   = try(toset(local.storageAccount.logAnalyticsWorkspaceId != null ? ["fileServices"] : []), {})
  name                       = "system"
  target_resource_id         = format("%s%s", azurerm_storage_account.sa.id, "/fileServices/default")
  log_analytics_workspace_id = local.storageAccount.logAnalyticsWorkspaceId

  enabled_log {
    category = "StorageRead"
  }

  enabled_log {
    category = "StorageWrite"
  }

  enabled_log {
    category = "StorageDelete"
  }

  metric {
    category = "Capacity"
    enabled  = try(local.storageAccount.values.monitorDiagnosticSetting.fileServices.metric.capacity.enabled, true)
  }

  metric {
    category = "Transaction"
    enabled  = try(local.storageAccount.values.monitorDiagnosticSetting.fileServices.metric.capacity.enabled, false)
  }
}

resource "azurerm_monitor_diagnostic_setting" "queueServices" {
  for_each                   = try(toset(local.storageAccount.logAnalyticsWorkspaceId != null ? ["queueServices"] : []), {})
  name                       = "system"
  target_resource_id         = format("%s%s", azurerm_storage_account.sa.id, "/queueServices/default")
  log_analytics_workspace_id = local.storageAccount.logAnalyticsWorkspaceId

  enabled_log {
    category = "StorageRead"
  }

  enabled_log {
    category = "StorageWrite"
  }

  enabled_log {
    category = "StorageDelete"
  }

  metric {
    category = "Capacity"
    enabled  = try(local.storageAccount.values.monitorDiagnosticSetting.queueServices.metric.capacity.enabled, true)
  }

  metric {
    category = "Transaction"
    enabled  = try(local.storageAccount.values.monitorDiagnosticSetting.queueServices.metric.transaction.enabled, false)
  }
}

resource "azurerm_monitor_diagnostic_setting" "tableServices" {
  for_each                   = try(toset(local.storageAccount.logAnalyticsWorkspaceId != null ? ["tableServices"] : []), {})
  name                       = "system"
  target_resource_id         = format("%s%s", azurerm_storage_account.sa.id, "/tableServices/default")
  log_analytics_workspace_id = local.storageAccount.logAnalyticsWorkspaceId

  enabled_log {
    category = "StorageRead"
  }

  enabled_log {
    category = "StorageWrite"
  }

  enabled_log {
    category = "StorageDelete"
  }

  metric {
    category = "Capacity"
    enabled  = try(local.storageAccount.values.monitorDiagnosticSetting.tableServices.metric.capacity.enabled, true)
  }

  metric {
    category = "Transaction"
    enabled  = try(local.storageAccount.values.monitorDiagnosticSetting.tableServices.metric.transaction.enabled, false)
  }
}

resource "azurerm_monitor_metric_alert" "availabilityError" {
  name                = join("-", [local.storageAccountName, "availabilityError"])
  resource_group_name = local.storageAccount["resourceGroupName"]
  scopes              = [azurerm_storage_account.sa.id]
  description         = ""
  severity            = try(local.storageAccount.values.monitorMetricAlert.availabilityError.severity, length(regexall("live", lower(data.azurerm_subscription.current.display_name))) > 0 ? 1 : 3)
  auto_mitigate       = true
  frequency           = try(local.storageAccount.values.monitorMetricAlert.availabilityError.frequency, "PT1M")
  window_size         = try(local.storageAccount.values.monitorMetricAlert.availabilityError.windowSize, "PT1M")

  criteria {
    metric_namespace = "Microsoft.Storage/storageAccounts"
    metric_name      = "Availability"
    aggregation      = "Average"
    operator         = try(local.storageAccount.values.monitorMetricAlert.availabilityError.criteria.operator, "LessThan")
    threshold        = try(local.storageAccount.values.monitorMetricAlert.availabilityError.criteria.threshold, 100)
  }
}

resource "azurerm_key_vault_key" "customerManagedKey" {
  for_each     = toset(try(local.storageAccount.values.customerManagedKey, false) == true ? ["01"] : [])
  name         = format("%s-%s-%s-%s", "Key", "sa", azurerm_storage_account.sa.name, "RSA")
  key_vault_id = local.storageAccount.keyVault.id
  key_type     = "RSA"
  key_size     = 2048
  key_opts     = ["decrypt", "encrypt", "sign", "unwrapKey", "verify", "wrapKey"]
}
resource "azurerm_role_assignment" "customerManagedKeyRbac" {
  for_each             = toset(try(local.storageAccount.keyVault.enableRbacAuthorization, false) == true ? ["01"] : [])
  scope                = azurerm_key_vault_key.customerManagedKey[each.key].resource_versionless_id
  role_definition_name = "Key Vault Crypto Service Encryption User"
  principal_id         = azurerm_storage_account.sa.identity.0.principal_id
}

resource "azurerm_key_vault_access_policy" "customerManagedKey" {
  for_each     = toset(try(local.storageAccount.keyVault.enableRbacAuthorization, false) == false ? ["01"] : [])
  key_vault_id = local.storageAccount.keyVault.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azurerm_storage_account.sa.identity.0.principal_id

  key_permissions = [
    "Get",
    "Create",
    "List",
    "Restore",
    "Recover",
    "UnwrapKey",
    "WrapKey",
    "Purge",
    "Encrypt",
    "Decrypt",
    "Sign",
    "Verify"
  ]
  secret_permissions = ["Get"]
}

resource "azurerm_storage_account_customer_managed_key" "sa" {
  for_each           = toset(try(local.storageAccount.values.customerManagedKey, true) == true ? ["01"] : [])
  storage_account_id = azurerm_storage_account.sa.id
  key_name           = azurerm_key_vault_key.customerManagedKey[each.key].name
  key_vault_id       = (
    try(local.storageAccount.keyVault.enableRbacAuthorization, false) == false ? 
    azurerm_key_vault_access_policy.customerManagedKey[each.key].key_vault_id : 
    replace(azurerm_role_assignment.customerManagedKeyRbac[each.key].scope, format("/keys/%s", azurerm_key_vault_key.customerManagedKey[each.key].name), "")
  )
  
}

resource "azurerm_storage_share" "share" {
  for_each           = { for x in try(local.storageAccount.values.share, []) : x.name => x }
  name               = each.value.name
  storage_account_id = azurerm_storage_account.sa.id
  quota              = each.value.quota
  enabled_protocol   = each.value.enabledProtocol
}

resource "azurerm_storage_container" "container" {
  for_each              = { for x in try(local.storageAccount.values.container, []) : x.name => x }
  name                  = each.value.name
  storage_account_id = azurerm_storage_account.sa.id
  container_access_type = try(each.value.containerAccessType, "private")
}

resource "azurerm_storage_table" "table" {
  for_each             = { for x in try(local.storageAccount.values.table, []) : x.name => x }
  name                 = each.value.name
  storage_account_name = azurerm_storage_account.sa.name
}

resource "azurerm_storage_queue" "queue" {
  for_each             = { for x in try(local.storageAccount.values.queue, []) : x.name => x }
  name                 = each.value.name
  storage_account_name = azurerm_storage_account.sa.name
}

resource "azurerm_storage_management_policy" "storageLifecycle" {
  for_each           = try(toset(local.storageAccount.values.lifeCycleRules != null ? ["01"] : []), {})
  storage_account_id = azurerm_storage_account.sa.id

  dynamic "rule" {
    for_each = try({ for r in local.storageAccount.values.lifeCycleRules : r.id => r }, [])
    content {
      name    = lower(join("-", ["Rule", rule.value.id]))
      enabled = rule.value.enabled
      filters {
        prefix_match = try(rule.value.filters.prefixMatch, []) #["container2/prefix1", "container2/prefix2"]
        blob_types   = try(rule.value.filters.blobTypes, [])   #["blockBlob"]
      }
      actions {
        dynamic "base_blob" {
          for_each = try(toset(rule.value.action.baseBlob != null ? ["01"] : []), {})
          content {
            delete_after_days_since_modification_greater_than              = try(rule.value.action.baseBlob.deleteAfterDaysSinceModificationGreaterThan, null)
            delete_after_days_since_last_access_time_greater_than          = try(rule.value.action.baseBlob.deleteAfterDaysSinceLastAccessTimeGreaterThan, null)
            tier_to_archive_after_days_since_last_access_time_greater_than = try(rule.value.action.baseBlob.tierToArchiveAfterDaysSinceLastAccessTimeGreaterThan, null)
            tier_to_archive_after_days_since_modification_greater_than     = try(rule.value.action.baseBlob.tierToArchiveAfterDaysSinceModificationGreaterThan, null)
            tier_to_cool_after_days_since_last_access_time_greater_than    = try(rule.value.action.baseBlob.tierToCoolAfterDaysSinceLastAccessTimeGreaterThan, null)
            tier_to_cool_after_days_since_modification_greater_than        = try(rule.value.action.baseBlob.tierToCoolAfterDaysSinceModificationGreaterThan, null)
          }
        }
        dynamic "snapshot" {
          for_each = try(toset(rule.value.action.snapshot != null ? ["01"] : []), {})
          content {
            change_tier_to_cool_after_days_since_creation    = try(rule.value.action.snapshot.changeTierToCoolAfterDaysSinceCreation, null)
            change_tier_to_archive_after_days_since_creation = try(rule.value.action.snapshot.changeTierToArchiveAfterDaysSinceCreation, null)
            delete_after_days_since_creation_greater_than    = try(rule.value.action.snapshot.deleteAfterDaysSinceCreationGreaterThan, null)
          }
        }
        dynamic "version" {
          for_each = try(toset(rule.value.action.version != null ? ["01"] : []), {})
          content {
            change_tier_to_cool_after_days_since_creation    = try(rule.value.action.version.changeTierToCoolAfterDaysSinceCreation, null)
            change_tier_to_archive_after_days_since_creation = try(rule.value.action.version.changeTierToArchiveAfterDaysSinceCreation, null)
            delete_after_days_since_creation                 = try(rule.value.action.version.deleteAfterDaysSinceCreationGreaterThan, null)
          }
        }

      }
    }
  }
}