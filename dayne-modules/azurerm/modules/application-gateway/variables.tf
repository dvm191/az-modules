variable "app_gateway_name" {
  description = "The name of the Application Gateway"
  type        = string
}

# variable "subnet_id" {
#   description = "The ID of the subnet"
#   type        = string
# }

variable "frontend_subnet_name" {
  description = "Name of the frontend subnet"
  type        = string
}

variable "backend_subnet_name" {
  description = "Name of the backend subnet"
  type        = string
}

variable "app_gateway_subnet_name" {
  description = "Name of the application gateway subnet"
  type        = string
}

variable "frontend_subnet_prefix" {
  description = "Address prefix for the frontend subnet"
  type        = string
}

variable "backend_subnet_prefix" {
  description = "Address prefix for the backend subnet"
  type        = string
}

variable "app_gateway_subnet_prefix" {
  description = "Address prefix for the application gateway subnet"
  type        = string
}

variable "public_ip_name" {
  description = "Name of the public IP address"
  type        = string
}

variable "location" {
  description = "Location of the resources"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "vnet_name" {
  description = "Name of the virtual network"
  type        = string
}



