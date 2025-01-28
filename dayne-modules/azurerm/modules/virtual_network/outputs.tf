output "resourceGroupName" {
  value = azurerm_virtual_network.vnet.resource_group_name
}

output "name" {
  value = azurerm_virtual_network.vnet.name
}
output "id" {
  value = azurerm_virtual_network.vnet.id
}

output "address_space" {
  value = azurerm_virtual_network.vnet.address_space
}