output "public_ip" {
  value       = azurerm_public_ip.this.ip_address
  description = "public ip of the application gateway, needed for the dns entry"
}

output "gateway_id" {
  value       = azurerm_application_gateway.this.id
  description = "Id of the application gateway, needed for aks integration"
}
