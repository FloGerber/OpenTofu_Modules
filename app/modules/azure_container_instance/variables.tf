variable "naming" {
  type = object({
    instance        = optional(string, "001")
    name_suffix     = optional(string)
    customer_number = string
  })
  validation {
    condition     = can(regex("^[0-9]{2}[1-9]$", var.naming.instance))
    error_message = "The instance number must be a number between 001 and 999!"
  }
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
  description = "Input the Resource Group Name for the Container Instance"
}

variable "environment" {
  type        = string
  description = "Input the environment"
}

variable "location_name" {
  type        = string
  description = "Input the Location for the Container Instance"
}

variable "ip_address_type" {
  type        = string
  description = "Input the IP Address Type which should be assigned, default to None"
  default     = "None"
}

variable "os_type" {
  type        = string
  description = "Input the OS type for the Container Group | Linux or Windows | default Linux"
  default     = "Linux"
}

variable "dns_name_label" {
  type        = string
  description = "Input the DNS Label for the Container Group IP"
  default     = ""
}

variable "use_identity" {
  type        = bool
  description = "Set to True if you want to assign a Identity to the Container Group"
  default     = false
}

variable "identity_type" {
  type        = string
  description = "Input the Identity Type you want to assign"
  default     = ""
}

variable "container" {
  type = map(
    object({
      name                         = string
      image                        = string
      cpu                          = optional(string, "0.5")
      cpu_limit                    = optional(string)
      memory                       = optional(string, "1")
      memory_limit                 = optional(string)
      ports                        = optional(map(string))
      secure_environment_variables = optional(map(string))
      environment_variables        = optional(map(string))
      readiness_probe              = optional(map(string))
      commands                     = optional(list(string))
      volume                       = optional(map(string))
  }))
  description = "Input the containers to deploy in the Container Group"
}

variable "dns_config" {
  type        = map(list(string))
  description = "Input the DNS Config for the Container Group"
  default     = null
}

variable "diagnostics_enabled" {
  type        = bool
  description = "Set to true to enable dignostics and log analytics"
  default     = false
}

variable "log_analytics" {
  type        = map(string)
  description = "Input the Log Analytics Settings"
  default     = null
}


variable "restart_policy" {
  type        = string
  description = "Input the Restart Policy for the Container Group"
  default     = "Always"
}

variable "image_registry_credential" {
  type = list(object({
    server   = string
    username = string
    password = string
  }))
  description = "Input the Image Registry and Credentials"
  #sensitive   = true
}

variable "tags" {
  description = "The tags to associate with your network and subnets."
  type        = map(string)

  default = {
    terraform = true
  }
}
