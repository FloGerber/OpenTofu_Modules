resource "azurecaf_name" "this" {
  resource_type = "azurerm_api_management"
  prefixes      = [join("", [substr("${var.environment}", 0, 1), var.naming.department_short_name]), join("", [var.naming.cloud_provider_short_name, var.naming.location_short_name])]
  suffixes      = var.naming.name_suffix != "" ? [var.naming.name_suffix, "${var.naming.instance}"] : ["${var.naming.instance}"]
}

resource "azurerm_api_management_authorization_server" "this" {
  name                         = "test-server"
  api_management_name          = data.azurerm_api_management.example.name
  resource_group_name          = data.azurerm_api_management.example.resource_group_name
  display_name                 = "Test Server"
  authorization_endpoint       = "https://example.mydomain.com/client/authorize"
  client_id                    = "42424242-4242-4242-4242-424242424242"
  client_registration_endpoint = "https://example.mydomain.com/client/register"

  grant_types = [
    "authorizationCode",
  ]
}