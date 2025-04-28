terraform {
  required_providers {
    azurecaf = {
      source  = "aztfmod/azurecaf"
      version = "~> 1.2.22"
    }
  }
}

resource "azurecaf_name" "this" {
  separator     = "_"
  resource_type = "general"
  prefixes      = [join("", [substr(var.environment, 0, 1), "PEP"]), local.resource_name]
  suffixes      = [local.subnet_name]
}

resource "azurecaf_name" "private_connection" {
  resource_type = "azurerm_private_service_connection"
  prefixes      = [substr(var.environment, 0, 1)]
  suffixes      = [local.resource_name]
}

locals {
  subnet_name   = element(split("/", var.subnet_id), length(split("/", var.subnet_id)) - 1)
  resource_name = element(split("/", var.private_connection_resource_id), length(split("/", var.private_connection_resource_id)) - 1)
  resource_type = trimprefix(one(slice(split("/", var.private_connection_resource_id), 6, 7)), "Microsoft.")
  dns_map = {
    AzureCosmosDB = "privatelink.mongo.cosmos.azure.com"
    Web           = "privatelink.azurewebsites.net"
    KeyVault      = "privatelink.vaultcore.azure.net"
    DataFactory   = "privatelink.datafactory.azure.net"
    Storage = {
      blob = "privatelink.blob.core.windows.net"
      file = "privatelink.file.core.windows.net"
      dfs  = "privatelink.dfs.core.windows.net"
    }
  }
}

##############
##
## DNS Zone Data Inputs
##
##############ö

data "azurerm_private_dns_zone" "this" {
  provider            = azurerm.SharedSub
  name                = local.resource_type == "Storage" ? lookup(local.dns_map.Storage, var.subresource_type) : lookup(flatten(local.dns_map), local.resource_type)
  resource_group_name = "PRSG400300_001"
}

##############
##
## Private Endpoint 
##
##############

resource "azurerm_private_endpoint" "this" {
  location            = var.location_name
  name                = upper(azurecaf_name.this.result)
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_id

  private_service_connection {

    is_manual_connection           = var.is_manual_connection
    name                           = azurecaf_name.private_connection.result
    private_connection_resource_id = var.private_connection_resource_id
    subresource_names              = [var.subresource_type]
  }

  private_dns_zone_group {
    name                 = local.resource_type == "Storage" ? lookup(local.dns_map.Storage, var.subresource_type) : lookup(flatten(local.dns_map), local.resource_type)
    private_dns_zone_ids = [data.azurerm_private_dns_zone.this.id]
  }

  tags = {
    Stage       = title(var.environment)
    Function    = "Private Endpoint"
    Source      = local.resource_name
    Destination = local.subnet_name
  }

  lifecycle {
    precondition {
      condition     = local.resource_type == "Storage" && var.subresource_type != ""
      error_message = "If Private Endpoint Resource is storage Account, you need to define the Subresource Type, valid types are blob, file, dfs"
    }
  }
}
