output "key_vault_certificate_id" {
  description = "Output the ID from a Key Vault Certificate"
  value       = data.azurerm_key_vault_certificate.this.id
}

output "key_vault_certificate_secret_id" {
  description = "Output the Secret ID from a Key Vault Certificate"
  value       = data.azurerm_key_vault_certificate.this.secret_id
}

output "key_vault_certificate_name" {
  description = "Output the Name from a Key Vault Certificate"
  value       = data.azurerm_key_vault_certificate.this.name
}
