terraform {
  required_providers {
    azurecaf = {
      source  = "aztfmod/azurecaf"
      version = "~> 1.2.22"
    }
  }
}

resource "azurecaf_name" "this" {
  resource_types = ["azurerm_network_interface", "azurerm_virtual_machine"]
  prefixes       = [join("", [upper(substr("${var.environment}", 0, 1)), var.naming.segment])]
  suffixes       = [var.naming.functional_area, var.naming.type, var.naming.customer, var.instance_count] #var.naming.name_suffix != "" ? [var.naming.name_suffix, "${var.naming.instance}"] : ["${var.naming.instance}"]
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

resource "azurerm_virtual_machine" "this" {
  name                  = lookup(azurecaf_name.this.results, "azurerm_virtual_machine")
  location              = var.location_name
  resource_group_name   = var.resource_group_name
  network_interface_ids = azurerm_network_interface.this.*.id
  vm_size               = var.vm_size

  source_image_reference {
    publisher = var.image_reference["publisher"]
    offer     = var.image_reference["offer"]
    sku       = var.image_reference["sku"]
    version   = var.image_reference["version"]
  }

  storage_os_disk {
    name              = join("-", [lookup(azurecaf_name.this.results, "azurerm_virtual_machine"), "OSDisk"])
    caching           = "ReadOnly"
    create_option     = "FromImage"
    managed_disk_type = "Premium_LRS"
  }

  os_profile {
    computer_name  = "winhost01"
    admin_username = "exampleadmin"
    admin_password = "Password1234!"
  }

  os_profile_windows_config {
    timezone                  = "Pacific Standard Time"
    provision_vm_agent        = true
    enable_automatic_upgrades = true
  }
}

resource "azurerm_mssql_virtual_machine" "example" {
  virtual_machine_id = azurerm_virtual_machine.example.id
  sql_license_type   = "PAYG"
}
