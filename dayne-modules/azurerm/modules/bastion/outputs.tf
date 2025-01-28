output "bastion_id" {
  description = "The ID of the Bastion host"
  value       = azurerm_bastion_host.build.id
}

output "public_ip_address" {
  description = "The public IP address of the Bastion host"
  value       = azurerm_public_ip.address.ip_address
}