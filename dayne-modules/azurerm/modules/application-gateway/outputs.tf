output "application_gateway_id" {
  description = "The ID of the Application Gateway"
  value       = azurerm_application_gateway.agw.id
}

# output "public_ip_id" {
#   value = azurerm_public_ip.pip
# }

# output "public_ip_address" {
#   value = azurerm_public_ip.pip.ip_address
# }