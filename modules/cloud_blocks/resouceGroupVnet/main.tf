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

module "virtual_network" {
  source   = "../../azurerm/virtual_network"
  for_each = { for s in local.inputs.virtualNetwork : s.index => s }
  virtualNetwork = merge(
    {
      values                = each.value
      instance              = local.inputs.instance
      workload              = local.inputs.workload
      region                = local.inputs.region
      complianceLevel       = local.inputs.complianceLevel
      stage                 = local.inputs.stage      
      resourceGroupName     = module.resource_group[each.value.resourceGroupIndex].resourceGroupName
      logAnalyticsWorkspace = data.azurerm_log_analytics_workspace.management
      tags                  = try(merge(module.tenant.globalTags, try(each.value.tags, {}), try(local.inputs.tags, {})), {})
    }
  )
}

module "subnet" {
  source = "../../azurerm/subnet"
  for_each = {for s in local.inputs.subnet : s.index => s}
  subnet = merge (
    {
      values                = each.value
      instance              = local.inputs.instance
      workload              = local.inputs.workload
      region                = local.inputs.region
      complianceLevel       = local.inputs.complianceLevel
      stage                 = local.inputs.stage
      tags                  = try(merge(try(each.value.tags, {}), try(local.inputs.tags, {})), {})
      virtualNetwork        = module.virtual_network[each.value.virtualNetworkIndex]      
      logAnalyticsWorkspace = data.azurerm_log_analytics_workspace.management
    }
  )
}