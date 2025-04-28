terraform {
  required_providers {
    azurecaf = {
      source  = "aztfmod/azurecaf"
      version = "2.0.0-preview-2"
    }
  }
}
resource "azurecaf_name" "this" {
  resource_types = ["azurerm_kubernetes_cluster", "azurerm_resource_group"]
  prefixes       = [join("", [substr("${var.environment}", 0, 1), var.naming.department_short_name]), join("", [var.naming.cloud_provider_short_name, var.naming.location_short_name])]
  suffixes       = var.naming.name_suffix != "" ? [var.naming.name_suffix, "${var.naming.instance}"] : ["${var.naming.instance}"]
}

data "azurerm_kubernetes_service_versions" "current" {
  location       = var.location_name
  version_prefix = var.k8s_version
}

resource "azurerm_kubernetes_cluster" "this" {
  name                = lookup(azurecaf_name.this.results, "azurerm_kubernetes_cluster")
  location            = var.location_name
  resource_group_name = var.resource_group_name
  dns_prefix          = "${var.environment}-skynet-${var.naming.instance}"
  kubernetes_version  = data.azurerm_kubernetes_service_versions.current.latest_version
  # used to group all the internal objects of this cluster
  node_resource_group               = join("-", [lookup(azurecaf_name.this.results, "azurerm_resource_group"), "nodepool"])
  role_based_access_control_enabled = var.role_based_access_control

  default_node_pool {
    name                = join("", [var.naming.name_suffix, "nodepool"])
    enable_auto_scaling = true
    min_count           = var.min_node_count
    max_count           = var.max_node_count
    vm_size             = var.node_type
    os_disk_size_gb     = var.node_disk_size
    vnet_subnet_id      = var.subnet_id
  }

  ingress_application_gateway {
    # enabled    = true
    gateway_id = var.application_gateway_id
  }

  open_service_mesh_enabled = var.open_service_mesh_enabled

  key_vault_secrets_provider {
    secret_rotation_enabled  = true
    secret_rotation_interval = "5m"
  }

  service_principal {
    client_id     = var.service_principal_client_id
    client_secret = var.service_principal_client_secret
  }

  network_profile {
    network_plugin     = "azure"
    dns_service_ip     = var.dns_service_ip
    docker_bridge_cidr = "172.17.0.1/16"
    service_cidr       = var.service_cidr
  }

  azure_active_directory_role_based_access_control {
    managed                = true
    azure_rbac_enabled     = var.role_based_access_control
    admin_group_object_ids = ["58693f18-86a3-4253-8172-8731c56a9348", ] #DevOps Admin Group
  }

  local_account_disabled        = var.local_account_disabled
  private_dns_zone_id           = var.private_dns_zone_id
  private_cluster_enabled       = var.private_cluster_enabled
  public_network_access_enabled = var.public_network_access_enabled
  tags                          = var.tags
}
