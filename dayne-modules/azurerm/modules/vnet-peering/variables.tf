variable "source_vnet_id" {
  description = "The ID of the source VNet"
  type        = string
}

variable "destination_vnet_id" {
  description = "The ID of the destination VNet"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "peering_name" {
  description = "The name of the VNet peering"
  type        = string
}

variable "allow_forwarded_traffic" {
  description = "Allow forwarded traffic"
  type        = bool
  default     = true
}

variable "allow_gateway_transit" {
  description = "Allow gateway transit"
  type        = bool
  default     = false
}

variable "use_remote_gateways" {
  description = "Use remote gateways"
  type        = bool
  default     = false
}