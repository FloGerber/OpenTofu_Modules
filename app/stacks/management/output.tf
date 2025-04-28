output "jump_host_public_ip_address" {
  value       = module.jump_host.vm_public_ip
  description = "Output of the jump hosts Public IP Address"
}

output "proxy_url" {
  value       = "http://:${random_password.this.result}@localhost:8880/"
  description = "Output of the proxy URL used by kubectl"
  sensitive   = true
}
