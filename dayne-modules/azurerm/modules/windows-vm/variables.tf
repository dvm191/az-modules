variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "location" {
  description = "The Azure region where the resources will be created"
  type        = string
}


variable "vm_name" {
  description = "The name of the virtual machine"
  type        = string
}

variable "admin_username" {
  description = "The admin username for the VM"
  type        = string
}

variable "admin_password" {
  description = "The admin password for the VM"
  type        = string
  sensitive   = true
}

variable "vm_size" {
  description = "The size of the virtual machine"
  type        = string
  default     = "Standard_DS1_v2"
}

variable "os_disk_size_gb" {
  description = "The size of the OS disk in GB"
  type        = number
  default     = 127
}

variable "ip_configurations" {
  description = "A list of IP configuration objects with name, subnet_id, and allocation"
  type = list(object({
    name                          = string
    subnet_id                     = string
    private_ip_address_allocation = string
  }))
}

variable "os_disk_name" {
  description = "The name of the OS disk"
  type        = string
}

variable "os_disk_caching" {
  description = "The caching mode of the OS disk"
  type        = string
  default     = "ReadWrite"
}

variable "os_disk_create_option" {
  description = "The create option for the OS disk"
  type        = string
  default     = "FromImage"
}

variable "os_disk_managed_disk_type" {
  description = "The managed disk type of the OS disk"
  type        = string
  default     = "Standard_LRS"
}

variable "image_publisher" {
  description = "The publisher of the image"
  type        = string
  default     = "MicrosoftWindowsServer"
}

variable "image_offer" {
  description = "The offer of the image"
  type        = string
  default     = "WindowsServer"
}

variable "image_sku" {
  description = "The SKU of the image"
  type        = string
  default     = "2019-Datacenter"
}

variable "image_version" {
  description = "The version of the image"
  type        = string
  default     = "latest"
}

# testing