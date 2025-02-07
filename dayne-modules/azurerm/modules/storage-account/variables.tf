variable "storage_account_name" {
  description = "The name of the storage account."
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group."
  type        = string
}

variable "location" {
  description = "The Azure region where the storage account will be created."
  type        = string
}

variable "account_tier" {
  description = "The tier of the storage account."
  type        = string
  default     = "Standard"
}

variable "accountReplicationType" {
  description = "The replication type of the storage account."
  type        = string
  default     = "LRS"
}

variable "accountTier" {
  type = string
  default = "Standard"
}

variable "accessTier" {
  type = string
  default = "HOT"
}

variable "httpsTrafficOnlyEnabled" {
  type = string
}

variable "minTlsVersion" {
  type = string
}

variable "allowNestedItemsToBePublic" {
  type = bool
}

variable "publicNetworkAccessEnabled" {
  type = bool
}

variable "infrastructureEncryptionEnabled" {
  type = bool
}

variable "tags" {
  description = "A map of tags to assign to the resource."
  type        = map(string)
  default     = {}
}