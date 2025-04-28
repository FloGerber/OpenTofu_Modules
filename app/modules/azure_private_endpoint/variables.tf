###############
##
## Common Variables for naming, location, tagging and environment
##
###############

variable "location_name" {
  type        = string
  description = "Input the Location Name"
}

variable "resource_group_name" {
  type        = string
  description = "Input the Resource Group Name"
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

###############
##
## Private Endpoint parameters
##
###############

variable "subnet_id" {
  description = "The Subnet ID where the Private Endpoint will be placed"
  type        = string
}

variable "private_connection_resource_id" {
  description = "Input the Private Connection Resource ID"
  type        = string
}

variable "subresource_type" {
  description = "Input the Subresource Type if Resource is Storage Account"
  type        = string
  default     = ""
  validation {
    condition     = var.subresource_type != "" && can(contains(["blob", "file", "dfs"], var.subresource_type))
    error_message = "No valid Subresource Type was choosen, blob, file, dfs expected"
  }
}

variable "is_manual_connection" {
  description = "Flag to enable manual Connection of the Private Endpoint"
  type        = bool
  default     = false
}
