output "application_gateway_id" {
  description = "The ID of the Azure Application Gateway"
  value       = azurerm_application_gateway.network.id
}

output "application_gateway_name" {
  description = "The name of the Azure Application Gateway"
  value       = azurerm_application_gateway.network.name
}

output "application_gateway_sku" {
  description = "The SKU details of the Application Gateway"
  value       = azurerm_application_gateway.network.sku
}

output "application_gateway_frontend_ip_configuration" {
  description = "The frontend IP configuration details of the Application Gateway"
  value       = azurerm_application_gateway.network.frontend_ip_configuration
}

output "application_gateway_backend_pools" {
  description = "The backend address pools of the Application Gateway"
  value       = azurerm_application_gateway.network.backend_address_pool
}

output "application_gateway_http_listeners" {
  description = "The HTTP listeners of the Application Gateway"
  value       = azurerm_application_gateway.network.http_listener
}

output "application_gateway_request_routing_rules" {
  description = "The request routing rules of the Application Gateway"
  value       = azurerm_application_gateway.network.request_routing_rule
}

output "application_gateway_location" {
  description = "The location of the Application Gateway"
  value       = azurerm_application_gateway.network.location
}
