# locals {
#   # Object to define the SKU settings dynamically
#   sku = {
#     name     = "Standard_v2"
#     tier     = "Standard_v2"
#     capacity = 2
#   }

#   # Object to define the gateway IP configurations
#   gateway_ip_configurations = [
#     {
#       name      = "gateway-ip-config-1"
#       subnet_id = azurerm_subnet.example.id
#     }
#   ]

#   # Object to define the frontend ports
#   frontend_ports = [
#     {
#       name = "frontend-port-1"
#       port = 80
#     },
#     {
#       name = "frontend-port-2"
#       port = 443
#     }
#   ]

#   # Object to define the frontend IP configurations
#   frontend_ip_configurations = [
#     {
#       name                 = "frontend-ip-config-1"
#       public_ip_address_id = azurerm_public_ip.example.id
#     }
#   ]

#   # Object to define backend address pools
#   backend_address_pools = [
#     {
#       name = "backend-pool-1"
#     }
#   ]

#   # Object to define backend HTTP settings
#   backend_http_settings = [
#     {
#       name                  = "http-settings-1"
#       cookie_based_affinity = "Disabled"
#       path                  = "/path1/"
#       port                  = 80
#       protocol              = "Http"
#       request_timeout       = 60
#     }
#   ]

#   # Object to define HTTP listeners
#   http_listeners = [
#     {
#       name                           = "http-listener-1"
#       frontend_ip_configuration_name = "frontend-ip-config-1"
#       frontend_port_name             = "frontend-port-1"
#       protocol                       = "Http"
#     }
#   ]

#   # Object to define request routing rules
#   request_routing_rules = [
#     {
#       name                       = "routing-rule-1"
#       priority                   = 10
#       rule_type                  = "Basic"
#       http_listener_name         = "http-listener-1"
#       backend_address_pool_name  = "backend-pool-1"
#       backend_http_settings_name = "http-settings-1"
#     }
#   ]
# }

locals {
  applicationGateway = var.applicationGateway
  location = (
    lower(local.applicationGateway.region) == "eus" ?
    "EastUS" :
    lower(local.applicationGateway.region) == "eus2" ?
    "EastUS2" :
    lower(local.applicationGateway.region) == "gwc" ?
    "GermanyWestCentral" :
    lower(local.applicationGateway.region) == "gn" ?
    "GermanyNorth" :    
    lower(local.applicationGateway.region) == "jpe" ?
    "JapanEast" :    
    lower(local.applicationGateway.region) == "neu" ?
    "NorthEurope" :
    lower(local.applicationGateway.region) == "scus" ?
    "SouthCentralUS" :
    lower(local.applicationGateway.region) == "sea" ?
    "SouthEastAsia" :
    lower(local.applicationGateway.region) == "sgp" ?
    "Singapore" :
    lower(local.applicationGateway.region) == "weu" ?
    "WestEurope" :
    lower(local.applicationGateway.region) == "wus" ?
    "WestUS" :
    lower(local.applicationGateway.region) == "wus2" ?
    "WestUS2" :
    # make it required
    ""
  )

applicationGatewayName = lower(
format(
    "%s%s-%s%s-%s%s-%s",
    "agw",# resourcetype      
    local.applicationGateway.instance,
    local.applicationGateway.workload,
    local.applicationGateway.values.applicationID,
    local.applicationGateway.region,
    try(local.applicationGateway.complianceLevel, null) == null ? "" : format("-%s", local.applicationGateway.complianceLevel),
    local.applicationGateway.stage,      
    )
)

subnetIds = try(local.applicationGateway.virtualNetworkSubnetIds, null) != null ? [for i in matchkeys(values(local.applicationGatewayName.virtualNetworkSubnetIds), keys(local.applicationGatewayName.virtualNetworkSubnetIds), try(local.applicationGatewayName.values.networkRules.subnetIndex, []) ): i.id] : []
}

############################ defaultDataSources ##########################################
data "azurerm_subscription" "current" {}

################################ Resources ###############################################

resource "azurerm_application_gateway" "network" {
  name                = local.applicationGatewayName
  resource_group_name = local.applicationGateway.resourceGroupName
  location            = local.location
  sku {
    name     = try(local.applicationGateway.value.skuName, "Standard_v2")
    tier     = try(local.applicationGateway.value.skuTier, "Standard_v2")
    capacity = try(local.applicationGateway.values.skuCapacity, 2)
  }

  dynamic "gateway_ip_configuration" {
    for_each = local.applicationGateway.gatewayIpConfiguration

    content {
      name      = try(local.applicationGateway.value.gatewayIpConfiguration.name, "default-gateway-ip-config")
      subnet_id = try(concat(try(local.applicationGateway, []), local.subnetIds), [])
    }
  }

  dynamic "frontend_port" {
    for_each = local.applicationGateway.frontendPorts

    content {
      name = try(local.applicationGateway.frontendPorts.value.name, "default-frontend-port")
      port = try(local.applicationGateway.frontendPorts.value.port, 80)
    }
  }

  dynamic "frontend_ip_configuration" {
    for_each = local.applicationGateway.frontendIpConfigurations

    content {
      name                 = try(local.applicationGatewayfrontendIpConfigurations.value.name, "default-frontend-ip-config")
      public_ip_address_id = local.applicationGatewayfrontendIpConfigurations.value.publicIpAddressId
    }
  }

  dynamic "backend_address_pool" {
    for_each = local.applicationGateway.backendAddressPools

    content {
      name = try(local.applicationGateway.backendAddressPools.value.name, "default-backend-pool")
    }
  }

  dynamic "backend_http_settings" {
    for_each = local.applicationGateway.backendHttpSettings

    content {
      name                  = try(local.applicationGateway.backendHttpSettings.value.name, "default-http-settings")
      cookie_based_affinity = try(local.applicationGateway.backendHttpSettings.value.cookieBasedAffinity, "Disabled")
      path                  = try(local.applicationGateway.backendHttpSettings.value.path, "/")
      port                  = try(local.applicationGateway.backendHttpSettings.value.port, 80)
      protocol              = try(local.applicationGateway.backendHttpSettings.value.protocol, "Http")
      request_timeout       = try(local.applicationGateway.backendHttpSettings.value.requestTimeout, 60)
    }
  }

  dynamic "http_listener" {
    for_each = local.applicationGateway.httpListeners

    content {
      name                           = try(local.applicationGateway.httpListeners.value.name, "default-http-listener")
      frontend_ip_configuration_name = local.applicationGateway.httpListeners.value.frontendIpConfigurationName
      frontend_port_name             = local.applicationGateway.httpListeners.value.frontendPortName
      protocol                       = try(applicationGateway.httpListeners.value.protocol, "Http")
    }
  }

  dynamic "request_routing_rule" {
    for_each = local.applicationGateway.requestRoutingRules

    content {
      name                       = try(local.applicationGateway.requestRoutingRules.value.name, "default-routing-rule")
      priority                   = try(local.applicationGateway.requestRoutingRules.value.priority, 10)
      rule_type                  = try(local.applicationGateway.requestRoutingRules.value.rule_type, "Basic")
      http_listener_name         = local.applicationGateway.requestRoutingRules.value.httpListeneName
      backend_address_pool_name  = local.applicationGateway.requestRoutingRules.value.backendAddressPoolName
      backend_http_settings_name = local.applicationGateway.requestRoutingRules.value.backendHttpSettingsName
    }
  }
}
