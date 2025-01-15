variable "subnets" {
  description = "A list of subnets to create"
  type = list(object({
    name           = string
    address_prefix = string
  }))
}

variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "vnet_name" {
  description = "The name of the virtual network"
  type        = string
}