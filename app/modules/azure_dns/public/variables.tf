variable "environment" {
  type        = string
  description = "Input the environment"
}

variable "subscription_id" {
  type        = string
  description = "Input subscription ID"
}

variable "resource_group_name" {
  type        = string
  description = "The name of the resource group that contains the DNS zone where the records will be added."
}

variable "dns_zone_name" {
  type        = string
  description = "The name of the DNS zone within the given resource group where the records will be added."
}

variable "recordsets" {
  type = list(object({
    name    = string
    type    = string
    ttl     = number
    records = list(string)
  }))
  description = "List of DNS record objects to manage, in the standard terraformdns structure."
}

variable "tags" {
  description = "The tags to associate with your network and subnets."
  type        = map(string)

  default = {
    terraform = true
  }
}
