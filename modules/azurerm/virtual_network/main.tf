############################## localVariables ############################################
locals {
  virtualNetwork = var.virtualNetwork  
  location = (
    lower(local.virtualNetwork.region) == "eus" ?
    "EastUS" :
    lower(local.virtualNetwork.region) == "eus2" ?
    "EastUS2" :
    lower(local.virtualNetwork.region) == "gwc" ?
    "GermanyWestCentral" :
    lower(local.virtualNetwork.region) == "gn" ?
    "GermanyNorth" :    
    lower(local.virtualNetwork.region) == "jpe" ?
    "JapanEast" :    
    lower(local.virtualNetwork.region) == "neu" ?
    "NorthEurope" :
    lower(local.virtualNetwork.region) == "scus" ?
    "SouthCentralUS" :
    lower(local.virtualNetwork.region) == "sea" ?
    "SouthEastAsia" :
    lower(local.virtualNetwork.region) == "sgp" ?
    "Singapore" :
    lower(local.virtualNetwork.region) == "weu" ?
    "WestEurope" :
    lower(local.virtualNetwork.region) == "wus" ?
    "WestUS" :
    lower(local.virtualNetwork.region) == "wus2" ?
    "WestUS2" :
    # make it required
    ""
  )   
  virtualNetworkName = lower(
    format(
      "%s%s-%s%s-%s%s-%s",
      "vnet",# resourcetype      
      local.virtualNetwork.instance,
      local.virtualNetwork.workload,
      local.virtualNetwork.values.applicationID,
      local.virtualNetwork.region,
      try(local.virtualNetwork.complianceLevel, null) == null ? "" : format("-%s", local.virtualNetwork.complianceLevel),
      local.virtualNetwork.stage,      
    )
  )
  networkWatcherFlowLogName = lower(
    format(
      "%s-%s",
      "flog",
      local.virtualNetworkName 
    )
  )  
}

############################ defaultDataSources ##########################################
data "azurerm_subscription" "current" {}

################################ Resources ###############################################
resource "azurerm_virtual_network" "vnet" {
  name                = local.virtualNetworkName
  resource_group_name = local.virtualNetwork.resourceGroupName
  location            = local.location
  address_space       = local.virtualNetwork.values.addressSpace
  dns_servers         = try(local.virtualNetwork.values.dnsServers, [])
  tags                = try(local.virtualNetwork.tags, {})
  
  dynamic ddos_protection_plan  {
    for_each = try(local.virtualNetwork.values.ddosProtectionPlanEnabled, false) == true ? ["01"] : []
    content {
      id     = try(local.virtualNetwork.ddosProtectionPlanId, local.virtualNetwork.values.ddosProtectionPlanId)
      enable = local.virtualNetwork.values.ddosProtectionPlanEnabled
    }
  }

  dynamic encryption {
    #for_each = local.virtualNetwork.values.encryption != null ? [1] : []
    for_each = try(local.virtualNetwork.values.encryption, null) != null ? ["01"] : []
    content {
      enforcement = try(local.virtualNetwork.values.encryption.enforcement, "AllowUnencrypted")
    }
  }

  lifecycle {
    ignore_changes = [
      # Ignore changes to tags, e.g. because other services
      # updates these based on some ruleset managed elsewhere.
      tags,
    ]
  }    
}

resource "azurerm_monitor_diagnostic_setting" "vnet" {  
  name                       = "setbyterraform"
  target_resource_id         = azurerm_virtual_network.vnet.id
  log_analytics_workspace_id = local.virtualNetwork.logAnalyticsWorkspace.id

  enabled_log {
    category = "VMprotectionAlerts"
  }

  metric {
    category = "AllMetrics"
  }
}

resource "azurerm_network_watcher_flow_log" "vnet" {
  for_each                  = toset(try(local.virtualNetwork.values.networkWatcherFlowLog, null) != null ? ["01"] : [])
  name                      = local.networkWatcherFlowLogName
  network_watcher_name      = local.virtualNetwork.values.networkWatcherFlowLog.networkWatcherName
  resource_group_name       = local.virtualNetwork.values.networkWatcherFlowLog.resourceGroupName
  location                  = local.location
  target_resource_id        = azurerm_virtual_network.vnet.id
  storage_account_id        = format("%s%s%s%s%s%s", "/subscriptions/", data.azurerm_subscription.current.subscription_id, "/resourceGroups/", local.virtualNetwork.values.networkWatcherFlowLog.resourceGroupName, "/providers/Microsoft.Storage/storageAccounts/", local.virtualNetwork.values.networkWatcherFlowLog.storageAccountName) 
  enabled                   = try(local.virtualNetwork.values.networkWatcherFlowLog.enabled, true)

  retention_policy {
    enabled = try(local.virtualNetwork.values.networkWatcherFlowLog.retentionPolicy.enabled, true)
    days    = try(local.virtualNetwork.values.networkWatcherFlowLog.retentionPolicy.days, 7)
  }

  traffic_analytics {
    enabled               = try(local.virtualNetwork.values.networkWatcherFlowLog.trafficAnalytics.enabled, true)
    workspace_id          = local.virtualNetwork.logAnalyticsWorkspace.workspace_id
    workspace_region      = local.virtualNetwork.logAnalyticsWorkspace.location
    workspace_resource_id = local.virtualNetwork.logAnalyticsWorkspace.id
    interval_in_minutes   = try(local.virtualNetwork.values.networkWatcherFlowLog.trafficAnalytics.intervalInMinutes, 10)
  }
  version = try(local.virtualNetwork.values.networkWatcherFlowLog.networkWatcherFlowLog.version, "2")
  tags    = try(local.virtualNetwork.tags, {})

  lifecycle {
    ignore_changes = [
      # Ignore changes to tags, e.g. because other services
      # update these based on some ruleset managed elsewhere.
      tags,
    ]
  }  
}