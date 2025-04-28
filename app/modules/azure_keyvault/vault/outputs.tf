output "uri" {
  value       = azurerm_key_vault.vault.vault_uri
  description = "Output the vault URI"
}

output "id" {
  value       = azurerm_key_vault.vault.id
  description = "Output the Vault ID"
}

output "name" {
  value       = azurerm_key_vault.vault.name
  description = "Output of the Vaut Name"
}
