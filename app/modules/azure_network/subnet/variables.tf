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

variable "resource_group_name" {
  type        = string
  description = "Input the resource group for vnet"
}

variable "virtual_network_name" {
  type        = string
  description = "Input the name of Azure VNET the subnet should be linked to"
}

variable "address_prefixes" {
  type        = list(string)
  description = "Input the address prefixes to use for the subnet"
}

variable "environment" {
  type        = string
  description = "Input the environment"
}
variable "enforce_private_link_endpoint_network_policies" {
  type        = bool
  default     = false
  description = "Enable or Disable network policies for the private link endpoint on the subnet. Setting this to true will Disable the policy and setting this to false will Enable the policy. Default value is false"
}

## Perhaps interresing if we generate a seperate project for networking

# variable "subnets" {
#   type = any
#   # Example
#   default = {
#     "app" = {
#       address_prefixes = ["10.0.0.0/24"]
#       service_endpoints = ["Microsoft.Sql", "Microsoft.Storage"]
#     }
#     "db" = {
#       address_prefixes = ["10.0.1.0/24"]
#       enforce_private_link_endpoint_network_policies = false
#     }
#   }
# }
