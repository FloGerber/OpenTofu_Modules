output "certificate_vault_id" {
  value       = azurerm_key_vault_certificate.this.id
  description = "Output of the key vault certificate id"
}
