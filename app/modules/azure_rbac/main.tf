terraform {
  required_providers {
    azurecaf = {
      source  = "aztfmod/azurecaf"
      version = "2.0.0-preview-2"
    }
  }
}

# resource "azurecaf_name" "this" {
#   resource_type = "azurerm_role_assignment"
#   prefixes      = [substr("${var.environment}", 0, 1), "${var.naming.department_short_name}", "${var.naming.cloud_provider_short_name}", "${var.naming.location_short_name}"]
#   suffixes      = var.naming.name_suffix != "" ? [var.naming.name_suffix, "${var.naming.instance}"] : ["${var.naming.instance}"]
# }

resource "azurerm_role_assignment" "this" {
  for_each             = { for assignment in var.role_assignment : assignment.description => assignment }
  scope                = each.value.scope
  role_definition_name = each.value.role_definition_name
  principal_id         = each.value.principal_id
  description          = each.value.description
}
