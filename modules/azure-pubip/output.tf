output "public_ip_address" {
  description = "The public IP address"
  value       = azurerm_public_ip.pubip.ip_address
}

output "ip_address_id" {
  value = azurerm_public_ip.pubip.id
}