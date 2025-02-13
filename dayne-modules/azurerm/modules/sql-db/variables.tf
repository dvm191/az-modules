variable "db_name" {
  description = "The name of the SQL Database."
  type        = string
}

variable "license_type" {
  description = "The license type for the SQL Database."
  type        = string
}

variable "max_size_gb" {
  description = "The maximum size of the SQL Database in gigabytes."
  type        = number
}

variable "read_scale" {
  description = "Enable read scale for the SQL Database."
  type        = bool      
}

variable "sku_name" {
  description = "The SKU name for the SQL Database."
  type        = string
}

variable "zone_redundant" {
  description = "Enable zone redundancy for the SQL Database."
  type        = bool
  default     = false
}

variable "environment" {
  description = "The environment for the SQL Database."
  type        = string
}

variable "enclave_type" {
  description = "The enclave type for the SQL Database."
  type        = string
}

variable "identity_type" {
  description = "The type of identity for the SQL Database."
  type        = string
}

variable "prevent_destroy" {
  description = "Prevent the accidental destruction of the SQL Database."
  type        = bool 
}

variable "user_assigned_identity_id" {
  description = "The ID of the user-assigned identity."
  type        = string
}

variable "key_vault_key_id" {
  description = "The ID of the Key Vault key."
  type        = string
}

variable "server_id" {
  description = "The ID of the SQL Server."
  type        = string
}




