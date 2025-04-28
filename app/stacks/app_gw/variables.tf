variable "subscription_id" {
  type        = string
  description = "Input Subscription ID"
}

variable "location_name" {
  type        = string
  description = "Input the Location Name"
}

variable "resource_group_name" {
  type        = string
  description = "Input the Resource Group Name"
  default     = "global"
}

variable "app_gw_address_prefixes" {
  type        = list(string)
  description = "Input the App Gateway Address Prefixes"
}

variable "app_gw_private_ip_address" {
  type        = string
  description = "Input the App Gateways Private IPv4 Address"
}

variable "default_virtual_network_name" {
  type        = string
  description = "Input the AKS V-NET Name"
}

variable "public_ssl_password" {
  type        = string
  description = "Input the ssl password for the public certificate"
  sensitive   = true
}

variable "public_ssl_certificate" {
  type        = string
  description = "Input the SSL Certificat (pfx) including the full chain, needs to be BASE64 encoded"
  sensitive   = true
}

variable "environment" {
  type        = string
  description = "Input the environment"
}

variable "tags" {
  description = "The tags to associate with your network and subnets."
  type        = map(string)

  default = {
    terraform = true
  }
}

variable "instance" {
  type        = string
  description = "Input the Instance for the resource"
}

variable "vault_id" {
  type        = string
  description = "Input the Vault ID"
}