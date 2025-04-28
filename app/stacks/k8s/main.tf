data "azurerm_resource_group" "this" {
  # ID needed for role assignment
  name = "global"
}

data "azurerm_private_dns_zone" "internal" {
  name = var.environment == "production" ? "internal.x.x" : "internal.${var.environment}.x.x"
}

data "azurerm_virtual_network" "this" {
  name                = var.default_virtual_network_name
  resource_group_name = var.resource_group_name
}

module "acr" {
  source          = "../../modules/container_registry"
  subscription_id = "" # Azure Container Registry is on Subscription Common
}

locals {
  name = "-${var.instance}"
}

resource "azurerm_private_dns_zone" "this" {
  name                = "${var.environment}.privatelink.${var.location_name}.azmk8s.io"
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "this" {
  name                  = "${var.environment}-${local.name}-dns-network-link"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.this.name
  virtual_network_id    = data.azurerm_virtual_network.this.id
  tags                  = var.tags
}

module "k8s_service_principal" {
  source                          = "../../modules/service_principal"
  name                            = local.name
  environment                     = var.environment
  password_rotation_interval_days = 14
  description                     = "The Service Principal for our Kubernetes Cluster on Env ${var.environment}"
}

module "aks_nodepool_subnet" {
  naming = {
    name_suffix               = "aks"
    cloud_provider_short_name = lookup(local.cloud_provider_short_name, "azure")
    department_short_name     = lookup(local.department_short_name, "infrastructure_opertations")
    instance                  = var.instance
    location_short_name       = lookup(local.location_short_name, var.location_name)
  }
  source                                         = "../../modules/network/subnet"
  resource_group_name                            = var.resource_group_name
  virtual_network_name                           = var.default_virtual_network_name
  address_prefixes                               = var.aks_address_prefixes_01
  environment                                    = var.environment
  enforce_private_link_endpoint_network_policies = true
}

# module "aks_security_group" {
#   source              = "../../modules/network/security_group"
#   name                = "${var.environment}-${local.name}-security-group"
#   location_name       = var.location_name
#   resource_group_name = var.resource_group_name
#   environment         = var.environment
#   security_rules      = []
# }

# module "aks_nodepool_security_group_association" {
#   source            = "../../modules/network/association"
#   security_group_id = module.aks_security_group.security_group_id
#   subnet_id         = module.aks_nodepool_subnet.subnet_id
# }

module "aks" {
  source                          = "../../modules/kubernetes_cluster"
  environment                     = var.environment
  location_name                   = var.location_name
  resource_group_name             = var.resource_group_name
  subnet_id                       = module.aks_nodepool_subnet.subnet_id
  service_principal_client_id     = module.k8s_service_principal.client_id
  service_principal_client_secret = module.k8s_service_principal.client_secret
  application_gateway_id          = var.app_gw_id
  service_cidr                    = var.aks_service_cidr_01
  dns_service_ip                  = var.aks_dns_service_ip_01
  k8s_version                     = var.k8s_version
  private_cluster_enabled         = true
  private_dns_zone_id             = azurerm_private_dns_zone.this.id
  role_based_access_control       = true
  local_account_disabled          = true
  depends_on = [
    module.rbac
  ]
}

module "aks_gitlab_service_principal" {
  source                          = "../../modules/service_principal"
  name                            = "GitlabAksServicePrincipal"
  environment                     = var.environment
  password_rotation_interval_days = 14
  description                     = "Service Principal for Kubernetes API Access on Env ${var.environment}"
}

module "rbac" {
  source = "../../modules/rbac"
  role_assignment = [
    {
      description          = "Resource Group Reader for Kubernetes Service Principal"
      scope                = data.azurerm_resource_group.this.id
      role_definition_name = "Reader"
      principal_id         = module.k8s_service_principal.object_id
    },
    {
      description          = "Kubernetes Principal Access Container Registry Pull Access"
      scope                = module.acr.id
      role_definition_name = "AcrPull"
      principal_id         = module.k8s_service_principal.object_id
    },
    {
      # getting 'Code="ErrorApplicationGatewayForbidden" Message="Unexpected status code '403' while performing a GET on Application Gateway' otherwise
      description          = "K8s Contributor Access to APP GW"
      scope                = var.app_gw_id
      role_definition_name = "Contributor"
      principal_id         = module.k8s_service_principal.object_id
    },
    {
      description          = "Vault Role Assignment for K8s"
      scope                = var.vault_id
      role_definition_name = "Key Vault Administrator"
      principal_id         = module.k8s_service_principal.object_id
    },
    {
      description          = "Private DNS Zone Contributor for Global Service Principal"
      scope                = azurerm_private_dns_zone.this.id
      role_definition_name = "Private DNS Zone Contributor"
      principal_id         = ""
    },
    {
      description          = "Private DNS Zone Contributor for k8s"
      scope                = azurerm_private_dns_zone.this.id
      role_definition_name = "Private DNS Zone Contributor"
      principal_id         = module.k8s_service_principal.object_id
    },
  ]
}

module "rbac_service_principal_k8s_acces" {
  source = "../../modules/rbac"
  role_assignment = [
    {
      description          = "AKS Admin Role Assignment for Global Service Principal"
      scope                = module.aks.aks_id
      role_definition_name = "Azure Kubernetes Service RBAC Cluster Admin"
      principal_id         = ""
    },
    {
      description          = "AKS Admin Role Assignment for Gitlab AKS Principal"
      scope                = module.aks.aks_id
      role_definition_name = "Azure Kubernetes Service RBAC Cluster Admin"
      principal_id         = module.aks_gitlab_service_principal.object_id
    },
  ]
}

module "secrets" {
  source       = "../../modules/keyvault/secrets"
  key_vault_id = var.vault_id

  secret = {
    "kubeconfig" = {
      value        = sensitive(module.aks.kube_config_secret)
      content_type = "kube.conf"
    },
  }
}
