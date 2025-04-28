terraform {
  required_providers {
    azurecaf = {
      source  = "aztfmod/azurecaf"
      version = "2.0.0-preview-2"
    }
  }
}

resource "azurecaf_name" "this" {
  resource_types = ["azurerm_network_interface", "azurerm_linux_virtual_machine"]
  prefixes       = [join("", [substr("${var.environment}", 0, 1), var.naming.department_short_name]), join("", [var.naming.cloud_provider_short_name, var.naming.location_short_name])]
  suffixes       = var.naming.name_suffix != "" ? [var.naming.name_suffix, "${var.naming.instance}"] : ["${var.naming.instance}"]
}

#
# Network Interface Configuration
#

resource "azurerm_network_interface" "this" {
  count                         = length(var.network_interfaces)
  name                          = coalesce(var.network_interfaces[count.index].name, join("-", [lookup(azurecaf_name.this.results, "azurerm_network_interface"), "${count.index}"]))
  location                      = var.location_name
  resource_group_name           = var.resource_group_name
  enable_ip_forwarding          = var.network_interfaces[count.index].enable_ip_forwarding
  enable_accelerated_networking = var.network_interfaces[count.index].enable_accelerated_networking

  dynamic "ip_configuration" {
    for_each = var.network_interfaces[count.index].ip_configurations

    content {
      name                          = coalesce(ip_configuration.value["name"], join("-", [lookup(azurecaf_name.this.results, "azurerm_network_interface"), "-ip-0${count.index}"]))
      subnet_id                     = ip_configuration.value["subnet_id"]
      private_ip_address_allocation = ip_configuration.value["private_ip_address_allocation"]
      private_ip_address            = ip_configuration.value["private_ip_address"]
      public_ip_address_id          = ip_configuration.value["public_ip_address_id"]
      primary                       = ip_configuration.value["primary"]
    }
  }
  tags = var.tags
}

#
# Virtual Maschine Linux
#

resource "azurerm_linux_virtual_machine" "this" {
  count                      = !var.is_windows ? 1 : 0
  name                       = lookup(azurecaf_name.this.results, "azurerm_linux_virtual_machine")
  resource_group_name        = var.resource_group_name
  location                   = var.location_name
  availability_set_id        = var.availability_set_enabled ? var.availability_set_id : null
  size                       = var.vm_size
  network_interface_ids      = azurerm_network_interface.this.*.id
  provision_vm_agent         = true
  allow_extension_operations = false

  #source_image_id = var.image_reference["image_id"] ? 1 : null

  source_image_reference {
    publisher = var.image_reference["publisher"]
    offer     = var.image_reference["offer"]
    sku       = var.image_reference["sku"]
    version   = var.image_reference["version"]
  }

  os_disk {
    name                 = join("-", [lookup(azurecaf_name.this.results, "azurerm_linux_virtual_machine"), "osdisk"])
    caching              = var.os_caching
    storage_account_type = var.storage_account_type
  }

  admin_username = var.admin_username

  admin_ssh_key {
    username   = var.admin_username
    public_key = var.public_key
  }

  disable_password_authentication = var.disable_password_authentication
  encryption_at_host_enabled      = var.encryption_at_host_enabled
  secure_boot_enabled             = var.secure_boot_enabled

  custom_data = var.custom_data


  provisioner "remote-exec" {
    inline = [
      var.command_to_execute
    ]

    connection {
      type        = "ssh"
      user        = "terraform"
      host        = self.public_ip_address
      private_key = file("~/.ssh/ssh_key")
    }
  }

  tags = var.tags
}
