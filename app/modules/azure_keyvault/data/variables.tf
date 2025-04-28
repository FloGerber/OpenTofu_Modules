variable "key_vault_name" {
  description = "Input the Name of the Key Vault to retrieve informations"
  type        = string
}

variable "resource_group_name" {
  description = "Input the Resource Group of the Key Vault to retrieve informations"
  type        = string
}

variable "certificate_name" {
  description = "Input the name of the certificate you want to get"
  type        = string
  default     = "null"
}

variable "subscription_id" {
  description = "Input the Subscription ID where the Key Vault is located"
  type        = string
}
