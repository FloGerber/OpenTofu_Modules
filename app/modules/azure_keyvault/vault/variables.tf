variable "naming" {
  type = object({
    instance        = optional(string, "001")
    name_suffix     = optional(string)
    customer_number = string
  })
  validation {
    condition     = var.naming.name_suffix != null ? can(regex("^[a-z]{0,6}$", var.naming.name_suffix)) : true
    error_message = "The name suffix must be a lowercase string between 0 and 6 characters!"
  }
  validation {
    condition     = can(regex("^[0-9]{6}$", var.naming.customer_number))
    error_message = "You don't have specified a valid Customer Number"
  }
  description = "Input the naming parameters for autogenerator, if not fully provided it will use default and random values"
}

variable "resource_group_name" {
  type        = string
  description = "Input the Resource Group the vault should be created in"
}

variable "location_name" {
  type        = string
  description = "Input the Location for the vault"
}

variable "tenant_id" {
  type        = string
  description = "Input the tenantid for the vault"
}

variable "object_id" {
  type        = string
  description = "Input the principal id"
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
