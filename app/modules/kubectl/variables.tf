variable "naming" {
  type = object({
    instance                  = string
    name_suffix               = string
    department_short_name     = string
    cloud_provider_short_name = string
    location_short_name       = string
  })
  validation {
    condition     = can(regex("^[0-9]{2}[1-9]$", var.naming.instance))
    error_message = "The instance number must be a number between 001 and 999!"
  }
  validation {
    condition     = can(regex("^[a-z]{0,6}$", var.naming.name_suffix))
    error_message = "The name suffix must be a lowercase string between 0 and 6 characters!"
  }
  description = "Input the naming parameters for autogenerator, if not fully provided it will use default and random values"
  default = {
    instance                  = "001"
    name_suffix               = ""
    department_short_name     = "rd"
    cloud_provider_short_name = "az"
    location_short_name       = "gwc"
  }
}
variable "kube_ca_cert" {
  type      = string
  sensitive = true
}

variable "kube_host" {
  type = string
}

variable "environment" {
  type        = string
  description = "Input the environment"
}

variable "tenant_id" {
  type        = string
  description = "Input of the Tenant ID where the Vault is located"
}

variable "key_vault_read_sp_id" {
  type        = string
  description = "Input of the Vault Read Service Principal ID"
}

variable "key_vault_service_principal_client_id" {
  type        = string
  description = "Input of the Key Vault Service Principal Client ID"
  sensitive   = true
}

variable "key_vault_service_principal_client_secret" {
  type        = string
  description = "Input of the Key Vault Service Principal Client Secret"
  sensitive   = true
}

variable "key_vault_name" {
  type        = string
  description = "Input of the Key Vault Name"
}

variable "storage_class_name" {
  type        = string
  description = "Name of the storage class for later use with K8S volume claims"
}

variable "storage_account_name" {
  type        = string
  description = "Name of the storage to be created for K8S volume use"
}

variable "sku_name" {
  type        = string
  description = "sku name for file storage"
}

variable "location_name" {
  type        = string
  description = "Input the Location Name for storage"
}

variable "proxy_url" {
  type        = string
  description = "Input of the Proxy URL for Kubernetes Provider"
  sensitive   = true
}

# variable "null_var" {
#   type        = string
#   description = "This var is only there to enable dependency on the SSH Tunnel, after we have Provider config we cant use depends on!"
# }
