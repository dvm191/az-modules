# resource "azurerm_subnet" "frontend" {
#   name                 = "myAGSubnet"
#   resource_group_name  = var.resource_group_name
#   virtual_network_name = var.vnet_name
#   address_prefixes     = ["10.21.0.0/24"]
# }

# resource "azurerm_subnet" "backend" {
#   name                 = "myBackendSubnet"
#   resource_group_name  = var.resource_group_name
#   virtual_network_name = var.vnet_name
#   address_prefixes     = ["10.21.1.0/24"]
# }

# resource "azurerm_public_ip" "pip" {
#   name                = "myAGPublicIPAddress"
#   resource_group_name = var.resource_group_name
#   location            = var.location
#   allocation_method   = "Static"
#   sku                 = "Standard"
# }


resource "azurerm_application_gateway" "agw" {
  name                = var.app_gateway_name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 2
  }
  gateway_ip_configuration {
    name      = "my-gateway-ip-configuration"
    subnet_id = var.subnet_id
  }
  frontend_port {
    name = "frontend-port"
    port = 80
  }
  frontend_ip_configuration {
    name                 = "frontend-ip-configuration"
    public_ip_address_id = var.public_ip_address_id
  }
  backend_address_pool {
    name = "backend-address-pool"
  }
  backend_http_settings {
    name                  = "backend-http-settings"
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 20
  }
  http_listener {
    name                           = "http-listener"
    frontend_ip_configuration_name = "frontend-ip-configuration"
    frontend_port_name             = "frontend-port"
    protocol                       = "Http"
  }
  request_routing_rule {
    name                       = "routing-rule"
    rule_type                  = "Basic"
    http_listener_name         = "http-listener"
    backend_address_pool_name  = "backend-address-pool"
    backend_http_settings_name = "backend-http-settings"
  }
}