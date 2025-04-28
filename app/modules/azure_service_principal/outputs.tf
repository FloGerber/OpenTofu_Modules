output "client_id" {
  value       = azuread_application.this.application_id
  description = "Output the Client/Application ID"
  sensitive   = true
}

output "object_id" {
  value       = azuread_service_principal.this.id
  description = "Output the Object ID"
}

output "client_secret" {
  value       = azuread_service_principal_password.this.value
  description = "Output the Service Principals Password"
  sensitive   = true
}
