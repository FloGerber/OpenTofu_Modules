# Create AVD workspace
resource "azurerm_virtual_desktop_workspace" "avd_workspace" {
  name                = "${var.stage}WKS${var.customer_number}_001"
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = contains(["Germany"], data.azurerm_resource_group.rg.location) ? "NorthEurope" : data.azurerm_resource_group.rg.location
  friendly_name       = var.workspace_friendly
  description         = var.workspace_friendly
  tags = {
    "Stage"    = local.select_stage
    "Function" = "Workspace"
    "Customer" = var.customer_number
  }
}

# Create AVD host pool
resource "azurerm_virtual_desktop_host_pool" "avd_hostpool" {
  resource_group_name      = azurerm_virtual_desktop_workspace.avd_workspace.resource_group_name
  location                 = azurerm_virtual_desktop_workspace.avd_workspace.location
  name                     = "${var.stage}${var.segment}HSP${var.customer_number}_001"
  validate_environment     = true
  custom_rdp_properties    = var.hostpool_rdp_settings
  type                     = "Pooled"
  maximum_sessions_allowed = var.hostpool_sessions
  load_balancer_type       = "DepthFirst" #[BreadthFirst DepthFirst]
  tags = {
    "Stage"    = local.select_stage
    "Location" = "${var.segment} (${var.segment_friendly})"
    "Function" = "Host Pool"
    "Customer" = var.customer_number
  }
}

# Create AVD DAG
resource "azurerm_virtual_desktop_application_group" "avd_dag" {
  resource_group_name          = azurerm_virtual_desktop_workspace.avd_workspace.resource_group_name
  host_pool_id                 = azurerm_virtual_desktop_host_pool.avd_hostpool.id
  location                     = azurerm_virtual_desktop_workspace.avd_workspace.location
  type                         = "Desktop"
  name                         = "${var.stage}${var.segment}DAG${var.customer_number}-001" # "_" not allowed
  default_desktop_display_name = var.default_desktop_display_name
  friendly_name                = var.desktop_applicationgroup_friendly
  description                  = var.desktop_applicationgroup_friendly
  depends_on = [
    azurerm_virtual_desktop_host_pool.avd_hostpool,
    azurerm_virtual_desktop_workspace.avd_workspace
  ]
  tags = {
    "Stage"    = local.select_stage
    "Location" = "${var.segment} (${var.segment_friendly})"
    "Function" = "Desktop Application Group"
    "Customer" = var.customer_number
  }
}

# Associate Workspace and DAG
resource "azurerm_virtual_desktop_workspace_application_group_association" "avd_ws-dag" {
  application_group_id = azurerm_virtual_desktop_application_group.avd_dag.id
  workspace_id         = azurerm_virtual_desktop_workspace.avd_workspace.id
}

# Create token for onboarding vms
resource "azurerm_virtual_desktop_host_pool_registration_info" "avd_registrationinfo" {
  hostpool_id     = azurerm_virtual_desktop_host_pool.avd_hostpool.id
  expiration_date = timeadd(timestamp(), "2h")
}

####### VMs ########

resource "random_password" "avd_password" {
  count            = var.avd_count
  length           = 32
  override_special = ".-#$"
}
resource "azurerm_key_vault_secret" "avd_password_kv" {
  provider     = azurerm.SharedSub
  count        = var.avd_count
  name         = "${local.avd_prefix}${format("%03d", count.index + 1)}"
  content_type = "nimda password"
  value        = random_password.avd_password[count.index].result
  key_vault_id = data.azurerm_key_vault.kv.id
}

resource "azurerm_network_interface" "avd_nic" {
  count               = var.avd_count
  name                = "${local.avd_prefix}${format("%03d", count.index + 1)}-nic"
  resource_group_name = data.azurerm_virtual_network.avd_vnet.resource_group_name
  location            = data.azurerm_virtual_network.avd_vnet.location

  ip_configuration {
    name                          = "nic${count.index + 1}_config"
    subnet_id                     = data.azurerm_subnet.avd_subnet.id
    private_ip_address_allocation = "Dynamic"
  }

  tags = {
    "Stage"           = local.select_stage
    "Location"        = "${var.segment} (${var.segment_friendly})"
    "Function"        = "Azure Virtual Desktop"
    "Functional Area" = var.functional_area
  }
}

resource "azurerm_windows_virtual_machine" "avd_vm" {
  count                 = var.avd_count
  name                  = "${local.avd_prefix}${format("%03d", count.index + 1)}"
  resource_group_name   = data.azurerm_resource_group.rg.name
  location              = data.azurerm_resource_group.rg.location
  size                  = var.avd_size
  network_interface_ids = ["${azurerm_network_interface.avd_nic.*.id[count.index]}"]
  provision_vm_agent    = true
  admin_username        = "nimda"
  admin_password        = random_password.avd_password[count.index].result

  os_disk {
    name                 = "${local.avd_prefix}${format("%03d", count.index + 1)}-osd"
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsDesktop"
    offer     = "Windows-11"
    sku       = "win11-21h2-avd"
    version   = "latest"
  }

  tags = {
    "Stage"           = local.select_stage
    "Location"        = "${var.segment} (${var.segment_friendly})"
    "Function"        = "Azure Virtual Desktop"
    "Functional Area" = var.functional_area
  }

  depends_on = [
    azurerm_network_interface.avd_nic
  ]
}

resource "azurerm_virtual_machine_extension" "domain_join" {
  count                      = var.avd_count
  name                       = "${local.avd_prefix}-${count.index + 1}-domainJoin"
  virtual_machine_id         = azurerm_windows_virtual_machine.avd_vm.*.id[count.index]
  publisher                  = "Microsoft.Compute"
  type                       = "JsonADDomainExtension"
  type_handler_version       = "1.3"
  auto_upgrade_minor_version = true

  settings = <<SETTINGS
    {
      "Name": "${var.domain_name}",
      "OUPath": "${var.ou_path}",
      "User": "${var.domain_user_upn}@${var.domain_name}",
      "Restart": "true",
      "Options": "3"
    }
SETTINGS

  protected_settings = <<PROTECTED_SETTINGS
    {
      "Password": "${data.azurerm_key_vault_secret.dom_svc_secret.value}" 
    }
PROTECTED_SETTINGS

  lifecycle {
    ignore_changes = [settings, protected_settings]
  }

}

resource "azurerm_virtual_machine_extension" "avd_vmext_dsc" {
  count                      = var.avd_count
  name                       = "${local.avd_prefix}${format("%03d", count.index + 1)}-dsc"
  virtual_machine_id         = azurerm_windows_virtual_machine.avd_vm.*.id[count.index]
  publisher                  = "Microsoft.Powershell"
  type                       = "DSC"
  type_handler_version       = "2.73"
  auto_upgrade_minor_version = true

  settings = <<-SETTINGS
    {
      "modulesUrl": "https://wvdportalstorageblob.blob.core.windows.net/galleryartifacts/Configuration_05-03-2022.zip",
      "configurationFunction": "Configuration.ps1\\AddSessionHost",
      "properties": {
        "HostPoolName":"${azurerm_virtual_desktop_host_pool.avd_hostpool.name}"
      }
    }
SETTINGS

  protected_settings = <<PROTECTED_SETTINGS
  {
    "properties": {
      "registrationInfoToken": "${local.registration_token}"
    }
  }
PROTECTED_SETTINGS

  depends_on = [
    azurerm_virtual_machine_extension.domain_join,
    azurerm_virtual_desktop_host_pool.avd_hostpool
  ]
}
