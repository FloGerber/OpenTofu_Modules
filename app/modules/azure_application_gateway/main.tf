terraform {
  required_providers {
    azurecaf = {
      source  = "aztfmod/azurecaf"
      version = "2.0.0-preview-2"
    }
  }
}

resource "azurecaf_name" "this" {
  resource_types = ["azurerm_public_ip", "azurerm_application_gateway"]
  prefixes       = [join("", [substr("${var.environment}", 0, 1), var.naming.department_short_name]), join("", [var.naming.cloud_provider_short_name, var.naming.location_short_name])]
  suffixes       = var.naming.name_suffix != "" ? [var.naming.name_suffix, "${var.naming.instance}"] : ["${var.naming.instance}"]
}

locals {
  app_gw_name                            = lookup(azurecaf_name.this.results, "azurerm_application_gateway")
  app_gw_public_ip_name                  = join("-", [lookup(azurecaf_name.this.results, "azurerm_public_ip"), "agw"])
  ssl_policy_name                        = join("-", [lookup(azurecaf_name.this.results, "azurerm_application_gateway"), "ssl-policy"])
  gateway_ip_configuration_name          = join("-", [lookup(azurecaf_name.this.results, "azurerm_application_gateway"), "gw-ip-config"])
  backend_address_pool_name              = join("-", [lookup(azurecaf_name.this.results, "azurerm_application_gateway"), "backend-address-pool"])
  frontend_ip_configuration_name         = join("-", [lookup(azurecaf_name.this.results, "azurerm_application_gateway"), "frontend-ip"])
  frontend_private_ip_configuration_name = join("-", [lookup(azurecaf_name.this.results, "azurerm_application_gateway"), "private-frontend-ip"])
  http_setting_name                      = join("-", [lookup(azurecaf_name.this.results, "azurerm_application_gateway"), "backend-http-settings"])
  listener_name                          = join("-", [lookup(azurecaf_name.this.results, "azurerm_application_gateway"), "http-listener"])
  request_routing_rule_name              = join("-", [lookup(azurecaf_name.this.results, "azurerm_application_gateway"), "route-rule"])
}

# Public Ip
resource "azurerm_public_ip" "this" {
  name                = local.app_gw_public_ip_name
  location            = var.location_name
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

resource "azurerm_application_gateway" "this" {
  name                = local.app_gw_name
  resource_group_name = var.resource_group_name
  location            = var.location_name
  enable_http2        = true

  autoscale_configuration {
    min_capacity = 0
    max_capacity = 2
  }
  # todo add WAF
  sku {
    name = var.sku
    tier = var.tier
  }

  waf_configuration {
    enabled          = true
    firewall_mode    = "Prevention"
    rule_set_type    = "OWASP"
    rule_set_version = "3.2"
  }

  ssl_policy {
    policy_type = "Custom"
    policy_name = local.ssl_policy_name
    cipher_suites = [
      "TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384",
      "TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256",
      "TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256",
      "TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384",
      "TLS_DHE_RSA_WITH_AES_128_GCM_SHA256"
    ]
    min_protocol_version = "TLSv1_2"
  }

  gateway_ip_configuration {
    name      = local.gateway_ip_configuration_name
    subnet_id = var.subnet_id
  }

  frontend_port {
    name = "httpPort"
    port = 80
  }

  frontend_port {
    name = "httpsPort"
    port = 443
  }

  frontend_ip_configuration {
    name                 = local.frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.this.id
  }

  frontend_ip_configuration {
    name                          = local.frontend_private_ip_configuration_name
    subnet_id                     = var.subnet_id
    private_ip_address            = var.private_ip_address
    private_ip_address_allocation = "Static"
  }

  backend_address_pool {
    name = local.backend_address_pool_name
  }

  backend_http_settings {
    name                  = local.http_setting_name
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 1
  }

  http_listener {
    name                           = local.listener_name
    frontend_ip_configuration_name = local.frontend_ip_configuration_name
    frontend_port_name             = "httpPort"
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = local.request_routing_rule_name
    rule_type                  = "Basic"
    http_listener_name         = local.listener_name
    backend_address_pool_name  = local.backend_address_pool_name
    backend_http_settings_name = local.http_setting_name
  }

  ssl_certificate {
    name     = "fondsfinanz.systems"
    data     = var.certificate
    password = var.password
  }

  lifecycle {
    ignore_changes = [
      tags,
      backend_address_pool,
      backend_http_settings,
      http_listener,
      ssl_certificate,
      redirect_configuration,
      frontend_port,
      probe,
      request_routing_rule,
      url_path_map
    ]
  }

  tags = var.tags
}
