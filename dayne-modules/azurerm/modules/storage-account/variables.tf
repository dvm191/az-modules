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

variable "sharedAccessKeyEnabled" {
  type = bool
  
}

variable "defaultToOauthAuthentication" {
  type = bool
}

variable "localUserEnabled" {
  type = bool
}

variable "sftpEnabled" {
  type = bool
}

variable "versioningEnabled" {
  type = bool 
}

variable "lastAccessTimeEnabled" {
  type = bool 
}

variable "bypass" {
  type = list(string)
  default = ["None"]
  
}

variable "defaultAction" {
  type = string
  default = "Deny"
  
}

variable "ipRules" {
  type = list(string)
  default = []
  
}

variable "virtualNetworkSubnetIds" {
  type = list(string)
  default = []
  
}

variable "container_name" {
  description = "The name of the storage container."
  type        = string
  
}

variable "container_access_type" {
  description = "The access level for the storage container."
  type        = string
  default     = "private"
  
}

variable "changeFeedEnabled" {
  type = bool
  
}