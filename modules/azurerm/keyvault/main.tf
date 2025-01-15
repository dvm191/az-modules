############################## localVariables ############################################
locals {
  keyVault = var.keyVault  
  location = (
    lower(local.keyVault.region) == "eus" ?
    "EastUS" :
    lower(local.keyVault.region) == "eus2" ?
    "EastUS2" :
    lower(local.keyVault.region) == "gwc" ?
    "GermanyWestCentral" :
    lower(local.keyVault.region) == "jpe" ?
    "JapanEast" :
    lower(local.keyVault.region) == "neu" ?
    "NorthEurope" :
    lower(local.keyVault.region) == "scus" ?
    "SouthCentralUS" :
    lower(local.keyVault.region) == "sea" ?
    "SouthEastAsia" :
    lower(local.keyVault.region) == "sgp" ?
    "Singapore" :
    lower(local.keyVault.region) == "weu" ?
    "WestEurope" :
    lower(local.keyVault.region) == "wus" ?
    "WestUS" :
    lower(local.keyVault.region) == "wus2" ?
    "WestUS2" :
    # make it required
    ""
  ) 
  keyVaultName = lower(
    format(
      "%s%s-%s-%s-%s%s-%s",
      "kv", # resourcetype
      local.keyVault.instance,
      local.keyVault.workload,
      local.keyVault.values.applicationID,
      local.keyVault.region,
      try(local.keyVault.complianceLevel, null) == null ? "" : format("-%s", local.keyVault.complianceLevel == "gxp" ? "g" : local.keyVault.complianceLevel == "nongxp" ? "ng" : ""),
      local.keyVault.stage,
    )
  )
  privateDnsZoneGroupVault = {
    name     = "vault"
    zoneName = "privatelink.vaultcore.azure.net"      
  }
  adGroupRole = try(flatten([
    for adgroup, roles in local.keyVault.values.authorization.adGroupRole : [
      for role in roles : {
        adGroupName   = adgroup
        adGroupRole   = role
      }
    ]
  ]), [])
  servicePrincipalRole = try(flatten([
    for serviceprincipal, roles in local.keyVault.values.authorization.servicePrincipalRole : [
      for role in roles : {
        servicePrincipalName  = serviceprincipal
        servicePrincipalRole  = role
      }
    ]
  ]), [])
  accessPolicyAdGroupRole = try(flatten([
    for x in local.keyVault.values.authorization.accessPolicy.adGroupRole : {
      adGroupName            = x.displayName
      keyPermissions         = try(x.keyPermissions, [])
      secretPermissions      = try(x.secretPermissions, [])
      certificatePermissions = try(x.certificatePermissions, [])
    }
  ]), [])
  accessPolicyServicePrincipalRole = try(flatten([
    for x in local.keyVault.values.authorization.accessPolicy.servicePrincipalRole : {
      servicePrincipalName   = x.displayName
      keyPermissions         = try(x.keyPermissions, [])
      secretPermissions      = try(x.secretPermissions, [])
      certificatePermissions = try(x.certificatePermissions, [])
    }
  ]), [])
  subnetIds = try(local.keyVault.virtualNetworkSubnetIds, null) != null ? [for i in matchkeys(values(local.keyVault.virtualNetworkSubnetIds), keys(local.keyVault.virtualNetworkSubnetIds), try(local.keyVault.values.networkAcls.subnetIndex, []) ): i.id] : []        
}

############################ defaultDataSources ##########################################
data "azurerm_client_config" "current" {}

################################ Resources ###############################################
resource "azurerm_key_vault" "kv" {
  name                          = local.keyVaultName
  resource_group_name           = local.keyVault.resourceGroupName
  location                      = local.location
  enable_rbac_authorization     = try(local.keyVault.values.enableRbacAuthorization, true)
  enabled_for_disk_encryption   = try(local.keyVault.values.enabledForDiskEncryption, false)
  public_network_access_enabled = try(local.keyVault.values.publicNetworkAccessEnabled, true)
  purge_protection_enabled      = try(local.keyVault.values.purgeProtectionEnabled, false)
  soft_delete_retention_days    = try(local.keyVault.values.softDeleteRetentionDays, 7)
  sku_name                      = try(local.keyVault.values.skuName, "standard")
  tenant_id                     = data.azurerm_client_config.current.tenant_id

  network_acls {
    bypass                     = try(local.keyVault.values.networkAcls.bypass, "None")
    default_action             = try(local.keyVault.values.networkAcls.defaultAction, "Allow")
    ip_rules                   = try(local.keyVault.values.networkAcls.ipRules, [])
    virtual_network_subnet_ids = try(concat(try(local.keyVault.values.networkAcls.virtualNetworkSubnetIds, []), local.subnetIds), [])
  }

  dynamic "contact" {
    for_each = try(local.keyVault.values.contact, [])

    content {
      email = contact.value.email
      name  = try(contact.value.name, null)
      phone = try(contact.value.phone, null)
    }
  }

  tags = try(local.keyVault.tags, {})

  lifecycle {
    ignore_changes = [
      # Ignore changes to tags, e.g. because other services
      # updates these based on some ruleset managed elsewhere.
      tags,
    ]
  }  
}

resource "azurerm_role_assignment" "currentUser" {
  for_each             = toset(try(local.keyVault.values.enableRbacAuthorization, true) == true ? ["currentUser"] : [])
  scope                = azurerm_key_vault.kv.id
  role_definition_name = "Key Vault Administrator"
  principal_id         = data.azurerm_client_config.current.object_id
}

data "azuread_group" "adGroupRole" {
  for_each = {
    for x in local.adGroupRole : format("%s.%s", x.adGroupName, x.adGroupRole) => x
    if try(local.keyVault.values.enableRbacAuthorization, false) == true
  }
  display_name = each.value.adGroupName
}

resource "azurerm_role_assignment" "adGroupRole" {
  for_each = {
    for x in local.adGroupRole : format("%s.%s", x.adGroupName, x.adGroupRole) => x
    if try(local.keyVault.values.enableRbacAuthorization, false) == true
  }
  scope                = azurerm_key_vault.kv.id
  role_definition_name = each.value.adGroupRole
  principal_id         = data.azuread_group.adGroupRole[each.key].object_id
}

data "azuread_service_principal" "servicePrincipalRole" {
  for_each = {
    for x in local.servicePrincipalRole : format("%s.%s", x.servicePrincipalName, x.servicePrincipalRole) => x
    if try(local.keyVault.values.enableRbacAuthorization, false) == true
  }
  display_name = each.value.servicePrincipalName
}

resource "azurerm_role_assignment" "servicePrincipalRole" {
  for_each = {
    for x in local.servicePrincipalRole : format("%s.%s", x.servicePrincipalName, x.servicePrincipalRole) => x
    if try(local.keyVault.values.enableRbacAuthorization, false) == true
  }
  scope                = azurerm_key_vault.kv.id
  role_definition_name = each.value.servicePrincipalRole
  principal_id         = data.azuread_service_principal.servicePrincipalRole[each.key].object_id
}

resource "azurerm_key_vault_access_policy" "currentUser" {
  for_each                = toset(try(local.keyVault.values.enableRbacAuthorization, false) != true ? ["currentUser"] : [])
  key_vault_id            = azurerm_key_vault.kv.id
  tenant_id               = data.azurerm_client_config.current.tenant_id
  object_id               = data.azurerm_client_config.current.object_id
  key_permissions         = ["Get", "List", "Update", "Create", "Delete", "Recover", "Purge", "GetRotationPolicy", "SetRotationPolicy"]
  secret_permissions      = ["Get", "List", "Set", "Delete", "Recover", "Purge"]
  certificate_permissions = ["Get", "List", "Create", "Import", "ManageContacts", "Delete", "Recover", "Purge"]
}

data "azuread_group" "accessPolicyAdGroupRole" {
  for_each = {
    for x in local.accessPolicyAdGroupRole : x.adGroupName => x
    if try(local.keyVault.values.enableRbacAuthorization, false) != true
  }
  display_name = each.value.adGroupName
}

resource "azurerm_key_vault_access_policy" "accessPolicyAdGroupRole" {
  for_each = {
    for x in local.accessPolicyAdGroupRole : x.adGroupName => x
    if try(local.keyVault.values.enableRbacAuthorization, false) != true
  }

  key_vault_id            = azurerm_key_vault.kv.id
  tenant_id               = data.azurerm_client_config.current.tenant_id
  object_id               = data.azuread_group.accessPolicyAdGroupRole[each.key].object_id
  key_permissions         = each.value.keyPermissions
  secret_permissions      = each.value.secretPermissions
  certificate_permissions = each.value.certificatePermissions
}

data "azuread_service_principal" "accessPolicyServicePrincipalRole" {
  for_each = {
    for x in local.accessPolicyServicePrincipalRole : x.servicePrincipalName => x
    if try(local.keyVault.values.enableRbacAuthorization, false) != true
  }
  display_name = each.value.servicePrincipalName
}

resource "azurerm_key_vault_access_policy" "accessPolicyServicePrincipalRole" {
  for_each = {
    for x in local.accessPolicyServicePrincipalRole : x.servicePrincipalName => x
    if try(local.keyVault.values.enableRbacAuthorization, false) != true
  }

  key_vault_id            = azurerm_key_vault.kv.id
  tenant_id               = data.azurerm_client_config.current.tenant_id
  object_id               = data.azuread_service_principal.accessPolicyServicePrincipalRole[each.key].object_id
  key_permissions         = each.value.keyPermissions
  secret_permissions      = each.value.secretPermissions
  certificate_permissions = each.value.certificatePermissions
}

resource "azurerm_private_endpoint" "privateEndpointVault" {
  for_each            = try(toset(local.keyVault.privateLinkSubnetId != null ? ["1"] : []), toset([])) 
  name                = lower(format("%s-%s-%s", azurerm_key_vault.kv.name, local.privateDnsZoneGroupVault.name, "privatelink"))
  resource_group_name = local.keyVault.resourceGroupName
  location            = local.location
  subnet_id           = local.keyVault.privateLinkSubnetId

  private_service_connection {
    name                           = lower(format("%s-%s-%s", azurerm_key_vault.kv.name, local.privateDnsZoneGroupVault.name, "privatelink"))
    private_connection_resource_id = azurerm_key_vault.kv.id
    is_manual_connection           = false
    subresource_names              = [local.privateDnsZoneGroupVault.name]
  }

  private_dns_zone_group {
    name                 = local.privateDnsZoneGroupVault.zoneName
    private_dns_zone_ids = local.keyVault.privateDnsZoneId.vault
  }

  # dynamic ip_configuration {
  #   for_each = try(each.value.ipConfiguration, [])

  #   content {
  #     name                = try(ip_configuration.value.name, "private")
  #     private_ip_address  = ip_configuration.value.privateIpAddress
  #     subresource_name    = try(ip_configuration.value.subresourceName, each.value.subresourceName)
  #   }
  # }
}

## Disabled for the moment, as this is beeing set by Azure Policy
# resource "azurerm_monitor_diagnostic_setting" "monitorDiagnosticSetting" {  
#   name                           = "system"
#   target_resource_id             = azurerm_key_vault.kv.id
#   log_analytics_workspace_id     = local.keyVault.logAnalyticsWorkspaceId

#   enabled_log {
#     category = "AuditEvent"

#     retention_policy {
#       enabled = try(local.keyVault.values.monitorDiagnosticSetting.log.auditEvent.retentionPolicy.enabled, false)
#       days    = try(local.keyVault.values.monitorDiagnosticSetting.log.auditEvent.retentionPolicy.days, 0)
#     }
#   }

#   enabled_log {
#     category = "AzurePolicyEvaluationDetails"

#     retention_policy {
#       enabled = try(local.keyVault.values.monitorDiagnosticSetting.log.azurePolicyEvaluationDetails.retentionPolicy.enabled, false)
#       days    = try(local.keyVault.values.monitorDiagnosticSetting.log.azurePolicyEvaluationDetails.retentionPolicy.days, 0)
#     }
#   }

#   metric {
#     category = "AllMetrics"
#     enabled  = try(local.keyVault.values.monitorDiagnosticSetting.metric.allMetrics.enabled, false)

#     retention_policy {
#       enabled = try(local.keyVault.values.monitorDiagnosticSetting.metric.allMetrics.retentionPolicy.enabled, false)
#       days    = try(local.keyVault.values.monitorDiagnosticSetting.metric.allMetrics.retentionPolicy.days, 0)
#     }
#   }
# }

resource "azurerm_monitor_metric_alert" "availabilityError" {
  name                = format("%s-%s", local.keyVaultName, "availabilityError")
  resource_group_name = local.keyVault.resourceGroupName
  scopes              = [azurerm_key_vault.kv.id]
  description         = ""
  severity            = try(local.keyVault.values.monitorMetricAlert.availabilityError.severity, 3)
  auto_mitigate       = true
  frequency           = try(local.keyVault.values.monitorMetricAlert.availabilityError.frequency, "PT1M")
  window_size         = try(local.keyVault.values.monitorMetricAlert.availabilityError.windowSize, "PT1M")

  criteria {
    metric_namespace = "Microsoft.KeyVault/vaults"
    metric_name      = "Availability"
    aggregation      = "Average"
    operator         = try(local.keyVault.values.monitorMetricAlert.availabilityError.criteria.operator, "LessThan")
    threshold        = try(local.keyVault.values.monitorMetricAlert.availabilityError.criteria.threshold, 100)
  }
}