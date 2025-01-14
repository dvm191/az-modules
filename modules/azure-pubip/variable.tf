variable "name" {
  description = "The name of the public IP address"
  type        = string
}

variable "location" {
  description = "The location where the public IP address will be created"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "allocation_method" {
  description = "The allocation method for the public IP address"
  type        = string
  default     = "Static"
}

variable "sku" {
  description = "The SKU of the public IP address"
  type        = string
  default     = "Basic"
}