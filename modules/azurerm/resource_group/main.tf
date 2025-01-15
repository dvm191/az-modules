############################## localVariables ############################################
locals {
  resourceGroup = var.resourceGroup  
  location = (
    lower(local.resourceGroup.region) == "eus" ?
    "EastUS" :
    lower(local.resourceGroup.region) == "eus2" ?
    "EastUS2" :
    lower(local.resourceGroup.region) == "gwc" ?
    "GermanyWestCentral" :
    lower(local.resourceGroup.region) == "jpe" ?
    "JapanEast" :
    lower(local.resourceGroup.region) == "neu" ?
    "NorthEurope" :
    lower(local.resourceGroup.region) == "scus" ?
    "SouthCentralUS" :
    lower(local.resourceGroup.region) == "sea" ?
    "SouthEastAsia" :
    lower(local.resourceGroup.region) == "sgp" ?
    "Singapore" :
    lower(local.resourceGroup.region) == "weu" ?
    "WestEurope" :
    lower(local.resourceGroup.region) == "wus" ?
    "WestUS" :
    lower(local.resourceGroup.region) == "wus2" ?
    "WestUS2" :
    # make it required
    ""
  )
  resourceGroupName = lower(
    format(
      "%s%s-%s-%s-%s%s-%s",
      "rg", # resourcetype
      local.resourceGroup.instance,
      local.resourceGroup.workload,
      local.resourceGroup.values.applicationID,
      local.resourceGroup.region,
      try(local.resourceGroup.complianceLevel, null) == null ? "" : format("-%s", local.resourceGroup.complianceLevel),
      local.resourceGroup.stage,
    )
  )
  aclAdUser = try(flatten([
    for aduser, roles in local.resourceGroup.values.aclAdUser : [
      for role in roles : {
        aduser = aduser
        role   = role
      }
    ]
  ]), [])  
  aclAdGroup = try(flatten([
    for adgroup, roles in local.resourceGroup.values.aclAdGroup : [
      for role in roles : {
        adgroup = adgroup
        role    = role
      }
    ]
  ]), [])
  aclServicePrincipal = try(flatten([
    for serviceprincipal, roles in local.resourceGroup.values.aclServicePrincipal : [
      for role in roles : {
        display_name = serviceprincipal
        role         = role
      }
    ]
  ]), [])

}

############################ defaultDataSources ##########################################
data "azurerm_subscription" "current" {}

############################ defaultDataSources ##########################################
resource "azurerm_resource_group" "rg" {  
  for_each = try(local.resourceGroup.values.name, null) == null ? toset(["01"]) : toset([])
  name     = local.resourceGroupName
  location = local.location
  tags     = try(local.resourceGroup.tags, {})

  lifecycle {
    ignore_changes = [
      # Ignore changes to tags, e.g. because other services
      # updates these based on some ruleset managed elsewhere.
      tags,
    ]
  }   
}

data "azuread_user" "aclAdUser" {
  for_each            = { for u in local.aclAdUser : join(".", [u.aduser, u.role]) => u }
  user_principal_name = each.value.aduser
}

resource "azurerm_role_assignment" "aclAdUser" {
  for_each             = { for u in local.aclAdUser : join(".", [u.aduser, u.role]) => u }
  scope                = length(azurerm_resource_group.rg) == 0 ? format("%s/%s/%s", data.azurerm_subscription.current.id, "resourceGroups", try(local.resourceGroup.values.name, "null")) : azurerm_resource_group.rg["01"].id
  role_definition_name = each.value.role
  principal_id         = data.azuread_user.aclAdUser[each.key].id
  description          = local.resourceGroup.values.description
}

data "azuread_group" "aclAdGroup" {
  for_each     = { for g in local.aclAdGroup : join(".", [g.adgroup, g.role]) => g }
  display_name = each.value.adgroup
}

resource "azurerm_role_assignment" "aclAdGroup" {
  for_each             = data.azuread_group.aclAdGroup
  scope                = length(azurerm_resource_group.rg) == 0 ? format("%s/%s/%s", data.azurerm_subscription.current.id, "resourceGroups", try(local.resourceGroup.values.name, "null")) : azurerm_resource_group.rg["01"].id
  role_definition_name = element(split(".", each.key), 1)
  principal_id         = each.value.id
  description          = local.resourceGroup.values.description
}

data "azuread_service_principal" "aclServicePrincipal" {
  for_each     = { for s in local.aclServicePrincipal : join(".", [s.display_name, s.role]) => s }
  display_name = each.value.display_name
}

resource "azurerm_role_assignment" "aclServicePrincipal" {
  for_each             = data.azuread_service_principal.aclServicePrincipal
  scope                = length(azurerm_resource_group.rg) == 0 ? format("%s/%s/%s", data.azurerm_subscription.current.id, "resourceGroups", try(local.resourceGroup.values.name, "null")) : azurerm_resource_group.rg["01"].id
  role_definition_name = element(split(".", each.key), 1)
  principal_id         = each.value.id
  description          = local.resourceGroup.values.description
}

resource "azurerm_management_lock" "rg" {
  for_each   = try(local.resourceGroup.values.lock.enabled, null) == true ? toset(["01"]) : toset([])
  name       = format("%s-%s-%s", lower(try(local.resourceGroup.values.lock.lockLevel, "CanNotDelete")) ,"lck", local.resourceGroupName)
  scope      = azurerm_resource_group.rg["01"].id
  lock_level = try(local.resourceGroup.values.lock.lockLevel, "CanNotDelete")
  notes      = try(local.resourceGroup.values.lock.notes, "Items can't be deleted in this resource group!")
}