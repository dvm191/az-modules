variable "name" {
  description = "The name of the Bastion host"
  type        = string
}

variable "location" {
  description = "The location where the Bastion host will be created"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "sku" {
  description = "The SKU of the Bastion host"
  type        = string
  default     = "Basic"
}

variable "subnet_id" {
  description = "The ID of the subnet for the Bastion host"
  type        = string
}

variable "public_ip_address_id" {
  description = "The ID of the public IP address for the Bastion host"
  type        = string
}