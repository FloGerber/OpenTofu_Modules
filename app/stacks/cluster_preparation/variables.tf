variable "environment" {
  type        = string
  description = "Input the environment"
}

variable "subscription_id" {
  type        = string
  description = "Input Subscription ID"
}

variable "gpg_encryption_key" {
  type        = string
  description = "Input the GPG Encryption Key"
  sensitive   = true
}

variable "vault_id" {
  type        = string
  description = "Input the Vault ID"
}

variable "kube_config" {
  type        = string
  description = "Input the Kubernetes Config, will be set to Gitlab"
  sensitive   = true
}

variable "kube_ca_cert" {
  type        = string
  description = "Input the Kubernetes CA Certificates"
  sensitive   = true
}

variable "kube_host" {
  type        = string
  description = "Input the Kubernetes Host"
}

variable "vault_name" {
  type        = string
  description = "Input the Keyvault Name"
}

variable "location_name" {
  type        = string
  description = "Input the Location Name"
}

variable "k8s_service_principal_object_id" {
  type        = string
  description = "k8s_service_principal_object_id"
}

variable "proxy_url" {
  type        = string
  description = "Input of the Proxy URL, wich is used by Kubernetes Provider and put as env var to gitlab"
  sensitive   = true
}

variable "aks_gitlab_service_principal_secret" {
  type        = string
  description = "Input of the AKS Gitlab Service Principal Secret"
  sensitive   = true
}

variable "aks_gitlab_service_principal_id" {
  type        = string
  description = "Input of the AKS Gitlab Service Principal ID"
  sensitive   = true
}
