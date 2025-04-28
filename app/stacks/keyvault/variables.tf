variable "location_name" {
  type        = string
  description = "Input the Location Name"
}

variable "resource_group_name" {
  type        = string
  description = "Input the Resource Group Name"
  default     = "global"
}

variable "subscription_id" {
  type        = string
  description = "Input Subscription ID"
}

variable "environment" {
  type        = string
  description = "Input the environment"
}

variable "instance" {
  type        = string
  description = "Input the Instance for the resource"
}

variable "default_virtual_network_name" {
  type        = string
  description = "Input of the Virtual Kubernetes Cluster Virtual Network Name"
}

variable "virtual_network_range" {
  type        = string
  description = "Input the Virtual Network Range to be allowed in bind"
}

variable "address_prefixes" {
  type        = list(string)
  description = "Input the address prefixes for the subnet"
}
