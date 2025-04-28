output "public_ip" {
  value       = module.app_gw.public_ip
  description = "Output the Public IP of the application gateway, needed for the dns entry"
}

output "private_ip" {
  value       = var.app_gw_private_ip_address
  description = "Output the Private IP of the application gateway, needed for the private dns entry"
}

output "gateway_id" {
  value       = module.app_gw.gateway_id
  description = "Output the Id of the application gateway, needed for aks integration"
}
