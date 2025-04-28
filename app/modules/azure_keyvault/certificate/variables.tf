variable "secret" {
  type        = any
  description = "Input the Secrets"
  # Example
  default = {
    "test" = {
      value           = "default_test_secret"
      content_type    = "some_text_you_want_example_kube.conf"
      expiration_date = "2023-11-22T00:10:00Z"
      not_before_date = null
    }
  }
}

variable "key_vault_id" {
  type        = string
  description = "Input the Key Vault ID for storeing the Secrets"
}
