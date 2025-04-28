resource "azurerm_key_vault_certificate" "this" {
  for_each     = var.certificate
  name         = each.key
  key_vault_id = var.key_vault_id

  certificate {
    contents = each.value.certificate_content
    password = each.value.certificate_password
  }
}

