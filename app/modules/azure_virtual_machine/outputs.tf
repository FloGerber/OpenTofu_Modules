output "vm_id" {
  value       = one(azurerm_linux_virtual_machine.this[*].id)
  description = "Output of the ID of the Virtual Machine"
}

output "vm_public_ip" {
  value       = one(azurerm_linux_virtual_machine.this[*].public_ip_address)
  description = "Output the Primary Public IP Address of the Virtual Machine"
}
