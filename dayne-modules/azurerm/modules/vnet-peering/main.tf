resource "azurerm_virtual_network_peering" "source_to_destination" {
  name                      = var.peering_name
  resource_group_name       = var.resource_group_name
  virtual_network_name      = var.source_vnet_id
  remote_virtual_network_id = var.destination_vnet_id

  allow_forwarded_traffic = try(var.allow_forwarded_traffic, true)
  allow_gateway_transit   = try(var.allow_gateway_transit, false)
  use_remote_gateways     = try(var.use_remote_gateways, false)
  
}

resource "azurerm_virtual_network_peering" "destination_to_source" {
  name                      = "${var.peering_name}-reverse"
  resource_group_name       = var.resource_group_name
  virtual_network_name      = var.destination_vnet_id
  remote_virtual_network_id = var.source_vnet_id

  allow_forwarded_traffic = try(var.allow_forwarded_traffic, true)
  allow_gateway_transit   = try(var.allow_gateway_transit, false)
  use_remote_gateways     = try(var.use_remote_gateways, false)
}