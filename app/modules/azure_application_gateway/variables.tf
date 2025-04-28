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
  description = "resource group for vnet"
}

variable "environment" {
  type        = string
  description = "Input the environment"
}

variable "location_name" {
  type        = string
  description = "location of vnet"
}

variable "sku" {
  description = "Name of the Application Gateway SKU."
  default     = "Standard_v2"
}

variable "subnet_id" {
  type        = string
  description = "Id of the gateway subnet"
}

variable "private_ip_address" {
  type        = string
  description = "Input the private IP of the APP Gateway"

}
variable "password" {
  type        = string
  description = "Input the the Certificat Password"
  sensitive   = true
}

variable "certificate" {
  type        = string
  description = "Input the BASE64 encoded PFX File"
  sensitive   = true
}

variable "tags" {
  description = "The tags to associate with your network and subnets."
  type        = map(string)

  default = {
    terraform = true
  }
}

variable "tier" {
  type        = string
  description = "Input the Tier you want to deploy"
  default     = "Standard_v2"
  sensitive   = true
}
