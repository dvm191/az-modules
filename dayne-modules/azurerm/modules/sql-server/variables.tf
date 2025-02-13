variable "location" {
  description = "The location/region where the SQL Server will be created."
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group in which the SQL Server will be created."
  type        = string
}

variable "sql_server_version" {
  description = "The version of the SQL Server."
  type        = string
  default     = "12.0"
}

variable "administrator_login" {
  description = "The administrator login for the SQL Server."
  type        = string
  
}

variable "administrator_login_password" {
  description = "The password for the administrator login."
  type        = string
}

variable "min_tls_version" {
  description = "The minimum TLS version for the SQL Server."
  type        = string
}

variable "identity_type" {
  description = "The type of identity to use for the SQL Server."
  type        = string
}

variable "enabled_for_disk_encryption" {
  description = "Should the Key Vault be enabled for disk encryption?"
  type        = bool
}

variable "soft_delete_retention_days" {
  description = "The number of days to retain soft deleted keys for."
  type        = number
}

variable "purge_protection_enabled" {
  description = "Should purge protection be enabled for the Key Vault?"
  type        = bool
}

variable "sku_name" {
  description = "The SKU name for the Key Vault."
  type        = string
}

variable "key_permissions" {
  description = "The permissions to grant to the Key Vault Key."
  type        = list(string)
}

variable "tenant_id" {
  description = "The Tenant ID for the Key Vault."
  type        = string
}

variable "sql_name" {
  description = "The name of the SQL Server."
  type        = string
  
}

variable "kv_name" {
  description = "The name of the Key Vault."
  type        = string
}

variable "user_assigned_admin" {
  description = "The name of the User Assigned Identity for the SQL Server administrator."
  type        = string
}

variable "elastic_pool_name" {
  description = "The name of the Elastic Pool."
  type        = string
}

variable "elastic_pool_sku_tier" {
  description = "The SKU name for the Elastic Pool."
  type        = string
}

variable "elastic_pool_sku_name" {
  description = "The SKU name for the Elastic Pool."
  type        = string
}

variable "elastic_pool_max_size_gb" {
  description = "The maximum size of the Elastic Pool in gigabytes."
  type        = number
}

variable "elastic_pool_dtu" {
  description = "The DTU for the Elastic Pool."
  type        = number
}

variable "elastic_pool_db_dtu_min" {
  description = "The minimum DTU for the databases in the Elastic Pool."
  type        = number
}

variable "elastic_pool_db_dtu_max" {
  description = "The maximum DTU for the databases in the Elastic Pool."
  type        = number

}