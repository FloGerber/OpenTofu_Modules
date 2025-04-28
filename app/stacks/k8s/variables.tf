variable "location_name" {
  type        = string
  description = "Input of the Location Name for the Kubernetes Cluster"
}

variable "resource_group_name" {
  type        = string
  description = "Input the Resource Group Name"
  default     = "global"
}

variable "default_virtual_network_name" {
  type        = string
  description = "Input of the Virtual Kubernetes Cluster Virtual Network Name"
}

variable "aks_address_prefixes_01" {
  type        = list(string)
  description = "Input of the Kubernetes Cluster Address Prefix"
}

variable "aks_address_prefixes_02" {
  type        = list(string)
  description = "Input of the Kubernetes Cluster Address Prefix"
}

variable "aks_dns_service_ip_01" {
  type        = string
  description = "Input of the Kubernetes Cluster DNS Service IP"
}

variable "aks_dns_service_ip_02" {
  type        = string
  description = "Input of the Kubernetes Cluster DNS Service IP"
}

variable "aks_service_cidr_01" {
  type        = string
  description = "Input of the Kubernetes Cluster Service CIDR"
}

variable "aks_service_cidr_02" {
  type        = string
  description = "Input of the Kubernetes Cluster Service CIDR"
}


variable "subscription_id" {
  type        = string
  description = "Input of the Subscription ID"
}

variable "tags" {
  description = "The tags to associate with your network and subnets."
  type        = map(string)

  default = {
    terraform = true
  }
}

variable "environment" {
  type        = string
  description = "Input the environment"
}

variable "app_gw_id" {
  type        = string
  description = "Input the Application Gateways ID used as Ingress Controller"
}

variable "vault_id" {
  type        = string
  description = "Input the Vault ID needed for RBAC"
}

variable "k8s_version" {
  type        = string
  description = "Kubernetes version"
}

variable "node_type" {
  type        = string
  description = "Azure VM type - see https://docs.microsoft.com/en-us/azure/virtual-machines/sizes + https://azure.microsoft.com/en-gb/pricing/vm-selector/"
}

variable "instance" {
  type        = string
  description = "Input the Instance for the resource"
}