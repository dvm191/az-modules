output "source_to_destination_peering_id" {
  value = azurerm_virtual_network_peering.source_to_destination.id
}

output "destination_to_source_peering_id" {
  value = azurerm_virtual_network_peering.destination_to_source.id
}

# testing