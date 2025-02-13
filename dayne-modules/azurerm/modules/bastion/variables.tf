variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "location" {
  description = "The location of the resources"
  type        = string
}

variable "vnet_name" {
  description = "The name of the virtual network"
  type        = string
}

variable "vnet_address_space" {
  description = "The address space of the virtual network"
  type        = list(string)
}

variable "subnet_address_prefixes" {
  description = "The address prefixes for the subnet"
  type        = list(string)
}

variable "public_ip_name" {
  description = "The name of the public IP address"
  type        = string
}

variable "bastion_name" {
  description = "The name of the Bastion host"
  type        = string
}

variable "bastion_subnet_name" {
  description = "The name of the Bastion host"
  type        = string
  default     = "AzureBastionSubnet"
}

variable "allocation_method" {
  description = "The allocation method of the public IP address"
  type        = string
}

variable "sku" {
  description = "The SKU of the Bastion host"
  type        = string
}