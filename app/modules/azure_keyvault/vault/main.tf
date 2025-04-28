terraform {
  required_providers {
    azurecaf = {
      source  = "aztfmod/azurecaf"
      version = "~> 1.2.22"
    }
  }
}

resource "azurecaf_name" "this" {
  resource_type = "azurerm_key_vault"
  prefixes      = [substr("${var.environment}", 0, 1)]
  suffixes      = var.naming.name_suffix != null ? [var.naming.customer_number, var.naming.name_suffix, "_${var.naming.instance}"] : [var.naming.customer_number, "_${var.naming.instance}"]
  separator     = ""
}

resource "azurerm_key_vault" "vault" {
  name                            = upper(azurecaf_name.this.result)
  location                        = var.location_name
  resource_group_name             = var.resource_group_name
  enabled_for_deployment          = true
  enabled_for_disk_encryption     = true
  enabled_for_template_deployment = true
  enable_rbac_authorization       = true
  tenant_id                       = var.tenant_id
  soft_delete_retention_days      = 90
  purge_protection_enabled        = false
  sku_name                        = "standard"
  tags = merge(var.tags, {
    Function = "Azure Key Vault"
    Customer = var.naming.customer_number
    Stage    = title(var.environment)
    }
  )
}
