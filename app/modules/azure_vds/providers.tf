terraform {
  required_providers {
    azurerm = {
      source                = "hashicorp/azurerm"
      configuration_aliases = [azurerm.SharedSub]
      version               = "~> 3.12.0"
    }
  }
}
