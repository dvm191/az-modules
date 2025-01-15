############################## localVariables ############################################
locals {
  inputs      = var.inputs.values
  environment = local.inputs.stage == "prd" ? "bnt" : "devbnt"
}

############################ defaultDataSources ##########################################
# data "azurerm_log_analytics_workspace" "management" {
#   provider            = azurerm.management
#   name                = module.tenant.environment[local.environment].management.logAnalyticsWorkspace[local.inputs.region].name
#   resource_group_name = module.tenant.environment[local.environment].management.logAnalyticsWorkspace[local.inputs.region].resourceGroupName
# }



# module "tenant" {
#   source = "../tenant"
# }

########################### modulesAndResources ##########################################
module "resource_group" {
  source   = "../../azurerm/resource_group"
  for_each = { for s in local.inputs.resourceGroup : s.index => s }
  resourceGroup = merge(
    {
      values          = each.value
      instance        = local.inputs.instance
      workload        = local.inputs.workload
      region          = local.inputs.region
      complianceLevel = local.inputs.complianceLevel
      stage           = local.inputs.stage
      #tags            = try(merge(module.tenant.globalTags, try(each.value.tags, {}), try(local.inputs.tags, {})), {})
    }
  )
}

resource "azurerm_management_lock" "resource_group" {
  for_each = { for s in local.inputs.resourceGroup : s.index => s }
  name       = format("%s-%s", "lock", module.resource_group[each.key].resourceGroupName)
  scope      = module.resource_group[each.key].id
  lock_level = each.value.lock.level
  notes      = each.value.lock.notes
  lifecycle {
    prevent_destroy = true
  }
}

module "storage_account" {
  source   = "../../azurerm/storage_account"
  for_each = { for s in local.inputs.storageAccount : s.index => s }
  storageAccount = merge(
    {
      values                  = each.value
      instance                = local.inputs.instance
      workload                = local.inputs.workload
      region                  = local.inputs.region
      complianceLevel         = local.inputs.complianceLevel
      stage                   = local.inputs.stage
      resourceGroupName       = module.resource_group[each.value.resourceGroupIndex].resourceGroupName
      #logAnalyticsWorkspaceId = data.azurerm_log_analytics_workspace.management.id
      #tags                    = try(merge(module.tenant.globalTags, try(each.value.tags, {}), try(local.inputs.tags, {})), {})
      keyVault                = module.key_vault[each.value.keyVaultIndex]
      privateLinkSubnetId     = try(each.value.privateEndpoint.privateLinkSubnetId, null)
      privateDnsZoneId = {
        blob  = try(each.value.privateEndpoint.blobPrivateDnsZoneId, null)
        file  = try(each.value.privateEndpoint.filePrivateDnsZoneId, null)
        table = try(each.value.privateEndpoint.tablePrivateDnsZoneId, null)
        queue = try(each.value.privateEndpoint.queuePrivateDnsZoneId, null)
      }
    }
  )
}

resource "azurerm_management_lock" "storage_account" {
  for_each = { for s in local.inputs.storageAccount : s.index => s }
  name       = format("%s-%s", "lock", module.storage_account[each.key].name)
  scope      = module.storage_account[each.key].id
  lock_level = each.value.lock.level
  notes      = each.value.lock.notes
  lifecycle {
    prevent_destroy = true
  }
}

module "key_vault" {
  source   = "../../azurerm/keyvault"
  for_each = { for s in local.inputs.keyVault : s.index => s }
  keyVault = merge(
    {
      values                  = each.value
      instance                = local.inputs.instance
      workload                = local.inputs.workload
      region                  = local.inputs.region
      complianceLevel         = local.inputs.complianceLevel
      stage                   = local.inputs.stage
      resourceGroupName       = module.resource_group[each.value.resourceGroupIndex].resourceGroupName
      #logAnalyticsWorkspaceId = data.azurerm_log_analytics_workspace.management.id
      #tags                    = try(merge(module.tenant.globalTags, try(each.value.tags, {}), try(local.inputs.tags, {})), {})
      privateLinkSubnetId     = try(each.value.privateEndpoint.privateLinkSubnetId, null)
      privateDnsZoneId = {
        vault  = try(each.value.privateEndpoint.privateDnsZoneId, null)
      } 
    }
  )
}

resource "azurerm_management_lock" "key_vault" {
  for_each = { for s in local.inputs.keyVault : s.index => s }
  name       = format("%s-%s", "lock", module.key_vault[each.key].name)
  scope      = module.key_vault[each.key].id
  lock_level = each.value.lock.level
  notes      = each.value.lock.notes
  lifecycle {
    prevent_destroy = true
  }
}