variable "location_name" {
  type        = string
  description = "Input of the Location Name for the Kubernetes Cluster"
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

variable "instance" {
  type        = string
  description = "Input the Instance for the resource"
}

variable "private_ip_address" {
  type        = string
  description = "Input the private IP Address for the Bind Server"
}

variable "admina_rsa" {
  type        = string
  description = "Input of the Default SSH key for admin access"
  sensitive   = true
}
