output "vault_id" {
  value       = module.vault.id
  description = "Output of the Key Vault ID"
}

output "vault_name" {
  value       = module.vault.name
  description = "Output of the "
  sensitive   = true
}
