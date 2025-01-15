output "vnet_id" {
  description = "The ID of the virtual network"
  value       = azurerm_virtual_network.my_terraform_network.id
}

output "subnet_ids" {
  value = {
    for subnet in azurerm_subnet.subnets : subnet.name => subnet.id
  }
}
