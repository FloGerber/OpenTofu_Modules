########
#
# IMPORTANT PRIVATE and PUBLIC DNS HAS SEPARATE RESOURCES 
#
########

resource "azurerm_private_dns_a_record" "this" {
  count = length(local.a_recordsets)

  resource_group_name = var.resource_group_name
  zone_name           = data.azurerm_private_dns_zone.this.name

  name    = coalesce(local.a_recordsets[count.index].name, "@")
  ttl     = local.a_recordsets[count.index].ttl
  records = local.a_recordsets[count.index].records
  tags    = var.tags
}

resource "azurerm_private_dns_aaaa_record" "this" {
  count = length(local.aaaa_recordsets)

  resource_group_name = var.resource_group_name
  zone_name           = data.azurerm_private_dns_zone.this.name

  name    = coalesce(local.aaaa_recordsets[count.index].name, "@")
  ttl     = local.aaaa_recordsets[count.index].ttl
  records = local.aaaa_recordsets[count.index].records
  tags    = var.tags
}

resource "azurerm_private_dns_cname_record" "this" {
  count = length(local.cname_records)

  resource_group_name = var.resource_group_name
  zone_name           = data.azurerm_private_dns_zone.this.name

  name   = coalesce(local.cname_records[count.index].name, "@")
  ttl    = local.cname_records[count.index].ttl
  record = local.cname_records[count.index].data
  tags   = var.tags
}
