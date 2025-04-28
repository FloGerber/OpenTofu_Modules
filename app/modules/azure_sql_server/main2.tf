resource "azurerm_network_interface" "vm_nic" {
  name                = "${var.vm_name}-NIC"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "${var.vm_name}-IP"
    subnet_id                     = var.vm_subnet_id
    private_ip_address_allocation = "Static"
    private_ip_address            = var.static_ip_address
  }
  tags = var.tags
}

resource "azurerm_network_interface_security_group_association" "vm_nic_sg" {
  network_interface_id      = azurerm_network_interface.vm_nic.id
  network_security_group_id = var.network_security_group_id
  count                     = var.network_security_group_id == "" ? 0 : 1
}

resource "azurerm_virtual_machine" "windows_vm" {
  name                             = var.vm_name
  vm_size                          = var.vm_size
  location                         = var.location
  resource_group_name              = var.resource_group_name
  availability_set_id              = var.availability_set_id
  delete_os_disk_on_termination    = var.vm_os_disk_delete_flag
  delete_data_disks_on_termination = var.vm_data_disk_delete_flag

  tags = merge(var.tags, { activityName = "${var.activity_tag} " })

  network_interface_ids = [
    azurerm_network_interface.vm_nic.id,
  ]

  storage_image_reference {
    publisher = var.publisher
    offer     = var.offer
    sku       = var.sku
    version   = var.image_version
  }

  identity {
    type = "SystemAssigned"
  }

  storage_os_disk {
    name              = "${var.vm_name}-OS"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Premium_LRS"
    disk_size_gb      = 128
  }

  storage_data_disk {
    name              = "${var.vm_name}-DATA"
    caching           = "ReadOnly"
    create_option     = "Empty"
    disk_size_gb      = 256
    lun               = 0
    managed_disk_type = "Premium_LRS"
  }

  storage_data_disk {
    name              = "${var.vm_name}-LOG"
    caching           = "ReadOnly"
    create_option     = "Empty"
    disk_size_gb      = 128
    lun               = 1
    managed_disk_type = "Premium_LRS"
  }

  os_profile {
    admin_password = var.admin_password
    admin_username = var.admin_username
    computer_name  = var.computer_name
  }

  os_profile_windows_config {
    timezone           = "UTC"
    provision_vm_agent = true
  }

  boot_diagnostics {
    enabled     = "true"
    storage_uri = var.storage_uri
  }

}
