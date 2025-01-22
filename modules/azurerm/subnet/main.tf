############################## localVariables ############################################
locals {
  subnet = var.subnet  
  location = (
    lower(local.subnet.region) == "eus" ?
    "EastUS" :
    lower(local.subnet.region) == "eus2" ?
    "EastUS2" :
    lower(local.subnet.region) == "gwc" ?
    "GermanyWestCentral" :
    lower(local.subnet.region) == "jpe" ?
    "JapanEast" :
    lower(local.subnet.region) == "neu" ?
    "NorthEurope" :
    lower(local.subnet.region) == "scus" ?
    "SouthCentralUS" :
    lower(local.subnet.region) == "sea" ?
    "SouthEastAsia" :
    lower(local.subnet.region) == "sgp" ?
    "Singapore" :
    lower(local.subnet.region) == "weu" ?
    "WestEurope" :
    lower(local.subnet.region) == "wus" ?
    "WestUS" :
    lower(local.subnet.region) == "wus2" ?
    "WestUS2" :
    # make it required
    ""
  )   
  subnetName = lower(
    format(
      "%s%s-%s-%s-%s%s-%s%s",
      "sub", # resourcetype 
      local.subnet.instance,
      local.subnet.workload,
      local.subnet.values.applicationID,
      local.subnet.region,
      try(local.subnet.complianceLevel, null) == null ? "" : format("-%s", local.subnet.complianceLevel),
      local.subnet.stage,
      try(local.subnet.values.tier, null) != null ? format("-%s", local.subnet.values.tier) : ""
    )
  )    
  networkSecurityGroupName = lower(
    format(
      "%s-%s",
      "nsg",
      local.subnetName      
    )
  )     
  networkWatcherFlowLogName = lower(
    format(
      "%s-%s",
      "flog",
      local.subnetName 
    )
  )   
  networkSecurityGroupRules = try(flatten([
    for rule in local.subnet.values.networkSecurityGroupRules : {
      name                                   = rule.name
      priority                               = rule.priority
      direction                              = try(rule.direction, "Inbound")
      access                                 = try(rule.access, "Allow")
      protocol                               = rule.protocol
      sourceAddressPrefix                    = try(rule.sourceAddressPrefix, null)
      sourceAddressPrefixes                  = try(rule.sourceAddressPrefixes, null)
      sourcePortRange                        = try(rule.sourcePortRange, "*")
      sourcePortRanges                       = try(rule.sourcePortRanges, null)
      sourceApplicationSecurityGroupIds      = try(rule.sourceApplicationSecurityGroupIds, [])
      destinationAddressPrefix               = try(rule.destinationAddressPrefix, null)
      destinationAddressPrefixes             = try(rule.destinationAddressPrefixes, null)
      destinationPortRange                   = try(rule.destinationPortRange, null)
      destinationPortRanges                  = try(rule.destinationPortRanges, null)
      destinationApplicationSecurityGroupIds = try(rule.destinationApplicationSecurityGroupIds, [])
    }
  ]), [])
}

############################ defaultDataSources ##########################################
data "azurerm_subscription" "current" {}

################################ Resources ###############################################
resource "azurerm_subnet" "snet" {
  name                                          = local.subnetName
  resource_group_name                           = local.subnet.virtualNetwork.resourceGroupName
  virtual_network_name                          = local.subnet.virtualNetwork.name
  address_prefixes                              = local.subnet.values.addressPrefixes
  service_endpoints                             = try(local.subnet.values.serviceEndpoints, [])
  #private_endpoint_network_policies_enabled     = try(local.subnet.values.privateEndpointNetworkPoliciesEnabled, "Disabled")
  private_link_service_network_policies_enabled = try(local.subnet.values.privateLinkServiceNetworkPoliciesEnabled, true)

  dynamic "delegation" {
    for_each = try(local.subnet.values.delegation, [])

    content {
      name = delegation.value.name

      service_delegation {
        name    = delegation.value.serviceDelegationName
        actions = delegation.value.serviceDelegationActions
      }
    }
  }
  default_outbound_access_enabled = try(local.subnet.values.defaultOutboundAccessEnabled, true)
}

resource "azurerm_network_security_group" "nsg" {
  name                = local.networkSecurityGroupName
  resource_group_name = local.subnet.virtualNetwork.resourceGroupName
  location            = local.location
  tags                = try(local.subnet.tags, {})

  lifecycle {
    ignore_changes = [
      # Ignore changes to tags, e.g. because other services
      # updates these based on some ruleset managed elsewhere.
      tags,
    ]
  }  
}

resource "azurerm_network_security_rule" "deny_all" {
  name                        = "deny_all"
  priority                    = 4000
  direction                   = "Inbound"
  access                      = "Deny"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = local.subnet.virtualNetwork.resourceGroupName
  network_security_group_name = azurerm_network_security_group.nsg.name
}

resource "azurerm_network_security_rule" "rule" {
  for_each = {
    for rule in local.networkSecurityGroupRules : format("%s_%s", rule.priority, rule.name) => rule
  }

  name                                       = each.value.name
  priority                                   = each.value.priority
  direction                                  = each.value.direction
  access                                     = each.value.access
  protocol                                   = each.value.protocol
  source_address_prefix                      = each.value.sourceAddressPrefix
  source_address_prefixes                    = each.value.sourceAddressPrefixes
  source_port_range                          = each.value.sourcePortRange
  source_port_ranges                         = each.value.sourcePortRanges
  source_application_security_group_ids      = each.value.sourceApplicationSecurityGroupIds
  destination_address_prefix                 = each.value.destinationAddressPrefix
  destination_address_prefixes               = each.value.destinationAddressPrefixes
  destination_port_range                     = each.value.destinationPortRange
  destination_port_ranges                    = each.value.destinationPortRanges
  destination_application_security_group_ids = each.value.destinationApplicationSecurityGroupIds
  resource_group_name                        = local.subnet.virtualNetwork.resourceGroupName
  network_security_group_name                = azurerm_network_security_group.nsg.name
}

resource "azurerm_subnet_network_security_group_association" "nsg" {
  subnet_id                 = azurerm_subnet.snet.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

resource "azurerm_subnet_route_table_association" "routeTable" {
  for_each       = toset(try(local.subnet.values.routeTableId, null) != null ? ["01"] : [])
  subnet_id      = azurerm_subnet.snet.id
  route_table_id = local.subnet.routeTableId
}

resource "azurerm_monitor_diagnostic_setting" "monitorDiagnosticSetting" {
  name                       = "system"
  target_resource_id         = azurerm_network_security_group.nsg.id
  log_analytics_workspace_id = local.subnet.logAnalyticsWorkspace.id

  enabled_log {
    category = "NetworkSecurityGroupEvent"
  }
}

resource "azurerm_network_watcher_flow_log" "snet" {
  for_each                  = toset(try(local.subnet.values.networkWatcherFlowLog, null) != null ? ["01"] : [])
  name                      = local.networkWatcherFlowLogName
  network_watcher_name      = local.subnet.values.networkWatcherFlowLog.networkWatcherName
  resource_group_name       = local.subnet.values.networkWatcherFlowLog.resourceGroupName
  location                  = local.location
  network_security_group_id = azurerm_network_security_group.nsg.id
  storage_account_id        = format("%s%s%s%s%s%s", "/subscriptions/", data.azurerm_subscription.current.subscription_id, "/resourceGroups/", local.subnet.values.networkWatcherFlowLog.resourceGroupName, "/providers/Microsoft.Storage/storageAccounts/", local.subnet.values.networkWatcherFlowLog.storageAccountName) 
  enabled                   = try(local.subnet.values.networkWatcherFlowLog.enabled, true)

  retention_policy {
    enabled = try(local.subnet.values.networkWatcherFlowLog.retentionPolicy.enabled, true)
    days    = try(local.subnet.values.networkWatcherFlowLog.retentionPolicy.days, 7)
  }

  traffic_analytics {
    enabled               = try(local.subnet.values.networkWatcherFlowLog.trafficAnalytics.enabled, true)
    workspace_id          = local.subnet.logAnalyticsWorkspace.workspace_id
    workspace_region      = local.subnet.logAnalyticsWorkspace.location
    workspace_resource_id = local.subnet.logAnalyticsWorkspace.id
    interval_in_minutes   = try(local.subnet.values.networkWatcherFlowLog.trafficAnalytics.intervalInMinutes, 10)
  }
  version = try(local.subnet.values.networkWatcherFlowLog.networkWatcherFlowLog.version, "2")
  tags    = try(local.subnet.tags, {})

  lifecycle {
    ignore_changes = [
      # Ignore changes to tags, e.g. because other services
      # update these based on some ruleset managed elsewhere.
      tags,
    ]
  }  
}