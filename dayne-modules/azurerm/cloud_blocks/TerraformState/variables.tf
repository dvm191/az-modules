variable "state_file_name" {
  description = "The name of the Terraform state file."
  type        = string
  default     = "terraform.tfstate"
}

variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "location" {
  description = "The location of the resources"
  type        = string
}

variable "storage_account_name" {
  description = "The name of the storage account"
  type        = string
}

variable "container_name" {
  description = "The name of the storage container"
  type        = string
}

variable "accountTier" {
  description = "The account tier for the storage account"
  type        = string
  default     = "Standard"
}

variable "accessTier" {
  description = "The access tier for the storage account"
  type        = string
  default     = "Hot"
}

variable "accountReplicationType" {
  description = "The replication type for the storage account"
  type        = string
  default     = "LRS"
}

variable "httpsTrafficOnlyEnabled" {
  description = "Enable HTTPS traffic only"
  type        = bool
  default     = true
}

variable "minTlsVersion" {
  description = "Minimum TLS version"
  type        = string
  default     = "TLS1_2"
}

variable "allowNestedItemsToBePublic" {
  description = "Allow nested items to be public"
  type        = bool
  default     = false
}

variable "publicNetworkAccessEnabled" {
  description = "Enable public network access"
  type        = bool
  default     = true
}

variable "infrastructureEncryptionEnabled" {
  description = "Enable infrastructure encryption"
  type        = bool
  default     = true
}

variable "sharedAccessKeyEnabled" {
  description = "Enable shared access key"
  type        = bool
  default     = true
}

variable "defaultToOauthAuthentication" {
  description = "Default to OAuth authentication"
  type        = bool
  default     = false
}

variable "localUserEnabled" {
  description = "Enable local user"
  type        = bool
  default     = true
}

variable "sftpEnabled" {
  description = "Enable SFTP"
  type        = bool
  default     = false
}

variable "versioningEnabled" {
  description = "Enable versioning"
  type        = bool
  default     = false
}

variable "changeFeedEnabled" {
  description = "Enable change feed"
  type        = bool
  default     = false
}

variable "lastAccessTimeEnabled" {
  description = "Enable last access time"
  type        = bool
  default     = false
}

variable "bypass" {
  description = "Network rules bypass"
  type        = list(string)
  default     = ["None"]
}

variable "defaultAction" {
  description = "Network rules default action"
  type        = string
  default     = "Deny"
}

variable "ipRules" {
  description = "Network rules IP rules"
  type        = list(string)
  default     = ["62.7.234.194/30"]
}

variable "virtualNetworkSubnetIds" {
  description = "Network rules virtual network subnet IDs"
  type        = list(string)
  default     = []
}

variable "container_access_type" {
  description = "The access type for the storage container"
  type        = string
  default     = "private"
}