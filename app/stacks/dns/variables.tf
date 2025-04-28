variable "subscription_id" {
  type        = string
  description = "Input Subscription ID"
}

variable "app_gw_public_ip_address" {
  type        = string
  description = "Input the App Gateways Public IPv4 Address"
}

variable "app_gw_private_ip_address" {
  type        = string
  description = "Input the App Gateways Private IPv4 Address"
}

variable "resource_group_name" {
  type        = string
  description = "Input the Resource Group Name"
  default     = "global"
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

variable "jump_host_public_ip_address" {
  type        = string
  description = "Input the Jump Hosts Public IP Address"
}
