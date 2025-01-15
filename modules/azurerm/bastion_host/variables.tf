## Common Variables

variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

## Bastion Host Variables
variable "bastion_host_name" {
  type = string
}

variable "virtual_network_name" {
  type = string
}

variable "subnet_address_space" {
  type = string
}