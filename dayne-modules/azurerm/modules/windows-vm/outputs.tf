output "vm_id" {
    description = "The ID of the Virtual Machine"
    value       = azurerm_virtual_machine.windows_vm.id
}

output "vm_name" {
    description = "The name of the Virtual Machine"
    value       = azurerm_virtual_machine.windows_vm.name
}

output "vm_public_ip" {
    description = "The public IP address of the Virtual Machine"
    value       = azurerm_public_ip.windows_vm.ip_address
}

output "vm_private_ip" {
    description = "The private IP address of the Virtual Machine"
    value       = azurerm_network_interface.windows_vm.private_ip_address
}