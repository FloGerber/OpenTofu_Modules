data "azuread_client_config" "this" {
}

provider "time" {
  # Configuration options
}

resource "time_offset" "days" {
  offset_days = 30
}

module "vault" {
  source = "../../modules/keyvault/vault"
  #name                = "vault-${var.instance}"
  location_name       = var.location_name
  resource_group_name = var.resource_group_name
  tenant_id           = data.azuread_client_config.this.tenant_id
  object_id           = data.azuread_client_config.this.object_id
  environment         = var.environment
}

module "rbac" {
  source = "../../modules/rbac"
  role_assignment = [
    {
      description          = "Vault Role Assignment for Devops"
      scope                = module.vault.id
      role_definition_name = "Key Vault Administrator"
      principal_id         = ""
    },
    {
      description          = "Vault Role Assignment for Global Service Principal"
      scope                = module.vault.id
      role_definition_name = "Key Vault Administrator"
      principal_id         = ""
    },
  ]
}

module "keyvault_privatelink_subnet" {
  naming = {
    name_suffix               = "kv"
    cloud_provider_short_name = lookup(local.cloud_provider_short_name, "azure")
    department_short_name     = lookup(local.department_short_name)
    instance                  = var.instance
    location_short_name       = lookup(local.location_short_name, var.location_name)
  }
  source                                         = "../../modules/network/subnet"
  resource_group_name                            = var.resource_group_name
  virtual_network_name                           = var.default_virtual_network_name
  address_prefixes                               = var.address_prefixes
  environment                                    = var.environment
  enforce_private_link_endpoint_network_policies = true
}

resource "azurerm_private_endpoint" "this" {
  name                = "vault-${var.instance}-private-endpoint"
  location            = var.location_name
  resource_group_name = var.resource_group_name
  subnet_id           = module.keyvault_privatelink_subnet.subnet_id
  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = ["/subscriptions/x/resourceGroups/global/providers/Microsoft.Network/privateDnsZones/", ]
  }
  private_service_connection {
    is_manual_connection           = false
    name                           = "vault-${var.instance}-private-endpoint-connect"
    private_connection_resource_id = module.vault.id
    subresource_names              = ["vault"]
  }
  lifecycle { ignore_changes = [tags] }
}

