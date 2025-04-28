variable "naming" {
  type = object({
    segment         = string
    functional_area = string
    type            = string
    customer        = string
  })
  # validation {
  #   condition     = can(regex("^[0-9]{1-3}$", var.naming.instance))
  #   error_message = "The instance number must be a number between 001 and 999!"
  # }
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

variable "location_name" {
  type        = string
  description = "Input the Location Name"
}

variable "resource_group_name" {
  type        = string
  description = "Input the Resource Group Name"
  default     = "global"
}

variable "environment" {
  type        = string
  description = "Input the environment"
}

variable "tags" {
  description = "The tags to associate with your network and subnets."
  type        = map(string)

  default = {
    terraform  = true
    terraspace = true
  }
}

variable "network_interfaces" {
  type = list(object({
    name                          = string
    enable_ip_forwarding          = bool
    enable_accelerated_networking = bool

    ip_configurations = list(object({
      name                          = string
      subnet_id                     = string
      private_ip_address_allocation = string
      public_ip_address_id          = string
      private_ip_address            = string
      primary                       = bool
    }))

  }))
  description = "Input the List of Network Interface objects"
}

variable "vm_size" {
  type        = string
  description = "Input the Size for the VM"
  default     = "Standard_D2s_v3"
}

variable "availability_set_enabled" {
  type        = bool
  description = "Input the true if you want to enable availability set, this will create a standby maschine for your vm / also doubles the costs!"
  default     = false
}

variable "image_reference" {
  type        = map(string)
  description = "Input the Image Reference for on of the public Images within Azure, you can also set and \"image_id\" for a custom image"
  default = {
    publisher = "MicrosoftSQLServer"
    offer     = "SQL2019-WS2022"
    sku       = "SQLSTANDARD"
    version   = "latest"
  }
}
