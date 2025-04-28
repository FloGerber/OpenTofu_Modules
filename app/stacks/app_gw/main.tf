locals {
  name = "app-gw-${var.instance}"
}

module "app_gw_subnet" {
  naming = {
    name_suffix               = "agw"
    cloud_provider_short_name = lookup(local.cloud_provider_short_name, "azure")
    department_short_name     = lookup(local.department_short_name)
    instance                  = var.instance
    location_short_name       = lookup(local.location_short_name, var.location_name)
  }
  source               = "../../modules/network/subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = var.default_virtual_network_name
  address_prefixes     = var.app_gw_address_prefixes
  # name                 = local.name # Just define some identifier, it will be automaticaly pre/suffixed.
  environment = var.environment
}

module "app_gw_security_group" {
  naming = {
    name_suffix               = "agw"
    cloud_provider_short_name = lookup(local.cloud_provider_short_name, "azure")
    department_short_name     = lookup(local.department_short_name)
    instance                  = var.instance
    location_short_name       = lookup(local.location_short_name, var.location_name)
  }
  source = "../../modules/network/security_group"
  # name                = "${var.environment}-${local.name}-security-group"
  location_name       = var.location_name
  resource_group_name = var.resource_group_name
  environment         = var.environment
  security_rules = [
    {
      name                       = "${var.environment}-${local.name}-rule-aks",
      priority                   = "105"
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "*"
      source_port_range          = "*"
      destination_port_range     = "65200-65535"
      source_address_prefix      = "GatewayManager"
      destination_address_prefix = "*"
    },
    {
      name                       = "HTTPS traffic",
      priority                   = "110"
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "443"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    },
    {
      name                       = "HTTPS Outbound traffic",
      priority                   = "107"
      direction                  = "Outbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "443"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    },
    {
      name                       = "HTTP traffic",
      priority                   = "109"
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "80"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    }
  ]
}

module "app_gw_subnet_security_group_association" {
  source            = "../../modules/network/association"
  security_group_id = module.app_gw_security_group.security_group_id
  subnet_id         = module.app_gw_subnet.subnet_id
}

module "public_ssl_secrets" {
  source       = "../../modules/keyvault/certificate"
  key_vault_id = var.vault_id

  certificate = {
    "public_ssl_cert" = {
      certificate_content  = var.public_ssl_certificate
      certificate_password = var.public_ssl_password
    },
  }
}

module "app_gw" {
  count               = 0
  source              = "../../modules/application_gateway"
  location_name       = var.location_name
  environment         = var.environment
  resource_group_name = var.resource_group_name
  subnet_id           = module.app_gw_subnet.subnet_id
  private_ip_address  = var.app_gw_private_ip_address
  password            = var.public_ssl_password
  certificate         = var.public_ssl_certificate
  sku                 = "WAF_v2"
  tier                = "WAF_v2"
}

module "api_mgmnt" {
  source              = "../../modules/api_management"
  location_name       = var.location_name
  environment         = var.environment
  resource_group_name = var.resource_group_name
  sku                 = "Developer_1" #RTFM the instance count is behind the SKU Name increase the number to scale
  publisher_name      = ""
  publisher_email     = "devops@.de"
  management_hostname_configuration = [
    {
      host_name    = var.environment == "production" ? "api.." : "api.${var.environment}."
      key_vault_id = module.public_ssl_secrets.id
    },
  ]
  # virtual_network_type          = ""
  # virtual_network_configuration = [""]
}
