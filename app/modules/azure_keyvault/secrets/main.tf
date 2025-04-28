resource "azurerm_key_vault_secret" "this" {
  for_each        = { for s, val in var.secret : s => val }
  name            = each.value.name # The key will be the name for the Secret
  value           = each.value.value
  key_vault_id    = var.key_vault_id
  content_type    = each.value.content_type
  not_before_date = try(each.value.not_before_date, null)
  expiration_date = try(each.value.expiration_date, null)
  tags            = var.tags
}
