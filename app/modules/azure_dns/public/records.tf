########
#
# IMPORTANT PRIVATE and PUBLIC DNS HAS SEPARATE RESOURCES 
#
########

resource "azurerm_dns_a_record" "this" {
  count = length(local.a_recordsets)

  resource_group_name = var.resource_group_name
  zone_name           = data.azurerm_dns_zone.this.name

  name    = coalesce(local.a_recordsets[count.index].name, "@")
  ttl     = local.a_recordsets[count.index].ttl
  records = local.a_recordsets[count.index].records
  tags    = var.tags
}

resource "azurerm_dns_aaaa_record" "this" {
  count = length(local.aaaa_recordsets)

  resource_group_name = var.resource_group_name
  zone_name           = data.azurerm_dns_zone.this.name

  name    = coalesce(local.aaaa_recordsets[count.index].name, "@")
  ttl     = local.aaaa_recordsets[count.index].ttl
  records = local.aaaa_recordsets[count.index].records
  tags    = var.tags
}

resource "azurerm_dns_cname_record" "this" {
  count = length(local.cname_records)

  resource_group_name = var.resource_group_name
  zone_name           = data.azurerm_dns_zone.this.name

  name   = coalesce(local.cname_records[count.index].name, "@")
  ttl    = local.cname_records[count.index].ttl
  record = local.cname_records[count.index].data
  tags   = var.tags
}

## UNCOMMENT WHEN REQUIRED - Failure if no record is defined

# resource "azurerm_dns_mx_record" "this" {
#   count = length(local.mx_recordsets)

#   resource_group_name = var.resource_group_name
#   zone_name           = data.azurerm_dns_zone.this.name

#   name = coalesce(local.mx_recordsets[count.index].name, "@")
#   ttl  = local.mx_recordsets[count.index].ttl

#   dynamic "record" {
#     for_each = mx_recordsets[count.index].records
#     content {
#       preference = split(record.value, " ")[0]
#       exchange   = split(record.value, " ")[1]
#     }
#   }
#  tags   = var.tags
# }

resource "azurerm_dns_ns_record" "this" {
  count = length(local.ns_recordsets)

  resource_group_name = var.resource_group_name
  zone_name           = data.azurerm_dns_zone.this.name

  name    = coalesce(local.ns_recordsets[count.index].name, "@")
  ttl     = local.ns_recordsets[count.index].ttl
  records = local.ns_recordsets[count.index].records
  tags    = var.tags
}

resource "azurerm_dns_ptr_record" "this" {
  count = length(local.ptr_recordsets)

  resource_group_name = var.resource_group_name
  zone_name           = data.azurerm_dns_zone.this.name

  name    = coalesce(local.ptr_recordsets[count.index].name, "@")
  ttl     = local.ptr_recordsets[count.index].ttl
  records = local.ptr_recordsets[count.index].records
  tags    = var.tags
}

## UNCOMMENT WHEN REQUIRED - Failure if no record is defined

# resource "azurerm_dns_srv_record" "this" {
#   count = length(local.srv_recordsets)

#   resource_group_name = var.resource_group_name
#   zone_name           = data.azurerm_dns_zone.this.name

#   name = coalesce(local.srv_recordsets[count.index].name, "@")
#   ttl  = local.srv_recordsets[count.index].ttl

#   dynamic "record" {
#     for_each = srv_recordsets[count.index].records
#     content {
#       priority = split(record.value, " ")[0]
#       weight   = split(record.value, " ")[1]
#       port     = split(record.value, " ")[2]
#       target   = split(record.value, " ")[3]
#     }
#   }
#  tags   = var.tags
# }

## UNCOMMENT WHEN REQUIRED - Failure if no record is defined

# resource "azurerm_dns_txt_record" "this" {
#   count = length(local.txt_recordsets)

#   resource_group_name = var.resource_group_name
#   zone_name           = data.azurerm_dns_zone.this.name

#   name = coalesce(local.txt_recordsets[count.index].name, "@")
#   ttl  = local.txt_recordsets[count.index].ttl

#   dynamic "record" {
#     for_each = txt_recordsets[count.index].records
#     content {
#       value = record.value
#     }
#   }
#  tags   = var.tags
# }
