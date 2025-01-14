output "bastion_host_id" {
  description = "The ID of the Bastion host"
  value       = azurerm_bastion_host.bastion.id
}