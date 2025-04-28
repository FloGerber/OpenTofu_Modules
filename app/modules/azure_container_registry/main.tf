provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

data "azurerm_container_registry" "this" {
  name                = "x"
  resource_group_name = "global"
}
