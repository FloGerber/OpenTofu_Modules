locals {
  avd_prefix         = "${var.stage}${var.segment}AVD${var.functional_area}V"
  registration_token = azurerm_virtual_desktop_host_pool_registration_info.avd_registrationinfo.token
  select_stage       = lookup({ P = "Production", I = "Integration", D = "Development" }, var.stage, "NotFound")
}

data "azurerm_key_vault" "kv" {
  name                = var.kv_name_friendly
  resource_group_name = var.kv_rg_name_friendly
  provider = azurerm.SharedSub
}

data "azurerm_resource_group" "rg"{
  name = var.rg_friendly
}

data "azurerm_virtual_network" "avd_vnet" {
  name                = var.avd_vnet_friendly
  resource_group_name = var.rg_friendly
}

data "azurerm_subnet" "avd_subnet" {
  name                 = var.avd_subnet_friendly
  virtual_network_name = var.avd_vnet_friendly
  resource_group_name  = var.rg_friendly
}

data "azurerm_key_vault_secret" "dom_svc_secret" {
  key_vault_id = data.azurerm_key_vault.kv.id
  name = var.domain_user_upn
  provider = azurerm.SharedSub
}

variable "stage" {
  description = "Deployment Stage"
  validation {
    condition     = contains(["P", "I", "D"], var.stage)
    error_message = "Allowed values: P (Production), I (Integration), D (Development)"
  }
}

variable "location" {
  description = "Location of the resourge group and resources"
  default     = "NorthEurope"
  validation {
    condition     = contains(["NorthEurope", "GermanyWestCentral"], var.location)
    error_message = "Allowed values: NorthEurope, GermanyWestCentral"
  }
}

variable "segment" {
  description = "Segment (3 digits)"
  validation {
    condition     = length(var.segment) == 3 && var.segment >= 0 && var.segment <= 250
    error_message = "Value must be 3 digits between 000 and 250"
  }
}

variable "segment_friendly" {
  description = "Segment friendly name"
}

variable "functional_area" {
  description = "Functional Area (3 digits)"
  validation {
    condition     = length(var.functional_area) == 3 && var.functional_area >= 1 && var.functional_area <= 250
    error_message = "Value must be 3 digits between 001 and 250"
  }
}

variable "functional_area_friendly" {
  description = "Functional area friendly name"
}

variable "rg_friendly" {
  description = "Ressource group friendly name"
}


variable "avd_vnet_friendly" {
  description = "Avd Vnet friendly name"
}

variable "avd_subnet_friendly" {
  description = "Avd subnet friendly name"
}

variable "kv_name_friendly" {
  description = "KeyVault friendly name"
  default = "PAKV600100001"
}

variable "kv_rg_name_friendly" {
  description = "KeyVault ressource group friendly name"
  default = "PRSG600100_001"
}

variable "customer_number" {
  description = "Customer number (6 digits)"
  validation {
    condition     = var.customer_number >= 200000 && var.customer_number <= 599999
    error_message = "Value must be between 200000 and 599999"
  }
}



########## AVD #########
variable "workspace_friendly" {
  description = "Friendly name of the workspace"
}

variable "hostpool_sessions" {
  description = "Numer of sessions per host in a given hostpool"
  default     = "16"
  validation {
    condition     = var.hostpool_sessions >= 1 && var.hostpool_sessions <= 32
    error_message = "Value must be between 1 and 32 sessions"
  }
}

variable "desktop_applicationgroup_friendly" {
  description = "Friendly name of the desktop application group "
  default     = "Default Desktop Application Group"
}

variable "default_desktop_display_name" {
  description = "Default Desktop Display friendly name"
}

variable "hostpool_rdp_settings" {
  type        = string
  description = "Connection Settings für RDP"
  default     = "drivestoredirect:s:;audiomode:i:2;videoplaybackmode:i:1;redirectclipboard:i:1;redirectprinters:i:0;devicestoredirect:s:;redirectcomports:i:0;redirectsmartcards:i:0;usbdevicestoredirect:s:;enablecredsspsupport:i:1;use multimon:i:1;audiocapturemode:i:0;encode redirected video capture:i:0;camerastoredirect:s:;redirectlocation:i:0;"
}

variable "avd_count" {
  description = "Number of AVD machines to deploy"
  validation {
    condition     = var.avd_count >= 1 && var.avd_count <= 32
    error_message = "Value must be between 1 and 32 session hosts"
  }
}

variable "avd_size" {
  description = "Size of the AVD vm(s)"
}


### Domain join ###
variable "domain_name" {
  description = "Name of the Domain"
  default = "appusr.com"
}

variable "ou_path" {
  description = "OU path"
}

variable "domain_user_upn" {
  description = "Domain Join Service Account UPN"
  default = "svc-400300-001"
}