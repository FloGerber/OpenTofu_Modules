module "public_dns" {
  source              = "../../modules/dns/public"
  environment         = var.environment
  resource_group_name = var.resource_group_name
  subscription_id     = "" # DNS is on Azure-Default
  dns_zone_name       = "dns.zone"

  recordsets = [
    {
      name = var.environment == "production" ? "*" : "*.${var.environment}"
      type = "A"
      ttl  = 60
      records = [
        "${var.app_gw_public_ip_address}"
      ]
    },
    {
      name = var.environment == "production" ? "domain" : "dopmain.${var.environment}"
      type = "A"
      ttl  = 60
      records = [
        "${var.jump_host_public_ip_address}"
      ]
    }
  ]
  tags = var.tags
}

module "private_dns" {
  source              = "../../modules/dns/private"
  resource_group_name = var.resource_group_name
  dns_zone_name       = var.environment == "production" ? "x.domain.net" : "internal.${var.environment}.domain.net"

  recordsets = [
    {
      name = "*"
      type = "A"
      ttl  = 60
      records = [
        "${var.app_gw_private_ip_address}",
      ]
    },
  ]
  tags = var.tags
}
