terraform {
  required_providers {
    azurecaf = {
      source  = "aztfmod/azurecaf"
      version = "~> 1.2.22"
    }
  }
}

resource "azurecaf_name" "this" {
  resource_types = ["azurerm_containerGroups"]
  prefixes       = [substr("${var.environment}", 0, 1)]
  suffixes       = var.naming.name_suffix != null ? [var.naming.customer_number, var.naming.name_suffix, "${var.naming.instance}"] : [var.naming.customer_number, "${var.naming.instance}"]
  separator      = ""
}

resource "azurerm_container_group" "this" {
  name                = upper(lookup(azurecaf_name.this.results, "azurerm_containerGroups"))
  location            = var.location_name
  resource_group_name = var.resource_group_name
  ip_address_type     = var.ip_address_type
  os_type             = var.os_type
  dns_name_label      = var.dns_name_label

  dynamic "identity" {
    for_each = var.use_identity == true ? [1] : []
    content {
      type         = var.identity_type
      identity_ids = var.identity_type != "SystemAssigned" ? [var.identity_ids] : []
    }
  }

  dynamic "container" {
    for_each = var.container
    content {
      name         = container.value.name
      image        = container.value.image
      cpu          = container.value.cpu
      cpu_limit    = container.value.cpu_limit
      memory       = container.value.memory
      memory_limit = container.value.memory_limit

      dynamic "ports" {
        for_each = container.value.ports == null ? [] : [1]
        content {
          port     = ports.value.port
          protocol = ports.value.protocol
        }
      }
      secure_environment_variables = container.value.secure_environment_variables
      environment_variables        = container.value.environment_variables
      dynamic "readiness_probe" {
        for_each = container.value.readiness_probe == null ? [] : [1]
        content {
          exec                  = readiness_probe.value.exec
          initial_delay_seconds = readiness_probe.value.initial_delay_seconds
        }
      }
      commands = container.value.commands
      dynamic "volume" {
        for_each = container.value.volume == null ? [] : [1]
        content {
          name       = volume.value.name
          mount_path = volume.value.mount_path
          share_name = volume.value.share_name
        }
      }
    }
  }

  dynamic "dns_config" {
    for_each = var.dns_config == null ? [] : [1]
    content {
      nameservers    = dns_config.value.nameservers
      search_domains = dns_config.value.search_domains
      options        = dns_config.value.options
    }
  }

  dynamic "diagnostics" {
    for_each = var.diagnostics_enabled == true ? [1] : []
    content {
      log_analytics {
        log_type      = var.log_analytics.log_type
        workspace_id  = var.log_analytics.workspace_id
        workspace_key = var.log_analytics.workspace_key
        metadata      = var.log_analytics.metadata
      }
    }
  }

  restart_policy = var.restart_policy

  dynamic "image_registry_credential" {
    for_each = [for registry_credential in var.image_registry_credential : {
      server   = registry_credential.server
      username = registry_credential.username
      password = registry_credential.password
    }]
    #for_each = var.image_registry_credential
    content {
      username = image_registry_credential.value.username
      password = image_registry_credential.value.password
      server   = image_registry_credential.value.server
    }

  }

  tags = merge(var.tags, {
    Function = "Container Group (ACI)"
    Customer = var.naming.customer_number
    Stage    = title(var.environment)
    }
  )
}
