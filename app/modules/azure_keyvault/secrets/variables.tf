variable "secret" {
  type = list(object({
    name            = string
    value           = string
    content_type    = string
    expiration_date = optional(string)
    not_before_date = optional(string, null)
  }))
  description = "Input the Secrets"
  # Example
  default = []
}

variable "tags" {
  description = "The tags to associate with your network and subnets."
  type        = map(string)

  default = {
    terraform = true
  }
}

variable "key_vault_id" {
  type        = string
  description = "Input the Key Vault ID for storeing the Secrets"
}
