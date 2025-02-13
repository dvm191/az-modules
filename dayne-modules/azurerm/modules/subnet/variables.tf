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

variable "subnet_name" {
  description = "The name of the subnet"
  default     = "frontend"
  type        = string
}

variable "subnet_address_prefixes" {
  description = "The address prefixes of the subnet"
  type        = list(string)
}

variable "nsg_name" {
  description = "The name of the network security group"
  default     = "frontend-nsg"
  type        = string
}

variable "security_rule" {
  description = "The security rule"
  default     = "Deny-All-Inbound"
  type        = string
}

variable "direction" {
  description = "The direction of the security rule"
  default     = "Inbound"
  type        = string 
}

variable "access" {
  description = "The access of the security rule"
  default     = "Deny"
  type        = string
  
}

variable "protocol" {
  description = "The protocol of the security rule"
  default     = "*"
  type        = string
}

variable "source_port_range" {
  description = "The source port range of the security rule"
  default     = "*"
  type        = string 
}

variable "destination_port_range" {
  description = "The destination port range of the security rule"
  default     = "*"
  type        = string
  
}

variable "source_address_prefix" {
  description = "The source address prefix of the security rule"
  default     = "*"
  type        = string
  
}

variable "destination_address_prefix" {
  description = "The destination address prefix of the security rule"
  default     = "*"
  type        = string
}
