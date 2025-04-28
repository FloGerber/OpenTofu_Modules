terraform {
  required_providers {
    azurecaf = {
      source  = "aztfmod/azurecaf"
      version = "2.0.0-preview-2"
    }
  }
}

resource "azurecaf_name" "this" {
  resource_type = "azurerm_subnet"
  prefixes      = [join("", [substr("${var.environment}", 0, 1), var.naming.department_short_name]), join("", [var.naming.cloud_provider_short_name, var.naming.location_short_name])]
  suffixes      = var.naming.name_suffix != "" ? [var.naming.name_suffix, "${var.naming.instance}"] : ["${var.naming.instance}"]
}

resource "azurerm_subnet" "this" {
  name                                           = azurecaf_name.this.result
  resource_group_name                            = var.resource_group_name
  virtual_network_name                           = var.virtual_network_name
  address_prefixes                               = var.address_prefixes
  enforce_private_link_endpoint_network_policies = var.enforce_private_link_endpoint_network_policies
}

