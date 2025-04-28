data "azurerm_private_dns_zone" "this" {
  # We request this only as an early check that it exists. We don't actually
  # need any additional information from it, since its identifier is its name.
  resource_group_name = var.resource_group_name
  name                = var.dns_zone_name
}

# Since the azurerm provider uses a separate resource type for each DNS record
# type, we'll need to split up our input list.
locals {
  recordsets       = { for rs in var.recordsets : rs.type => rs... }
  a_recordsets     = lookup(local.recordsets, "A", [])
  aaaa_recordsets  = lookup(local.recordsets, "AAAA", [])
  cname_recordsets = lookup(local.recordsets, "CNAME", [])
  mx_recordsets    = lookup(local.recordsets, "MX", [])
  ns_recordsets    = lookup(local.recordsets, "NS", [])
  ptr_recordsets   = lookup(local.recordsets, "PTR", [])
  srv_recordsets   = lookup(local.recordsets, "SRV", [])
  txt_recordsets   = lookup(local.recordsets, "TXT", [])

  # Some of the resources only deal with one record at a time, and so we need
  # to flatten these.
  cname_records = flatten([
    for rs in local.cname_recordsets : [
      for r in rs.records : {
        name = rs.name
        type = rs.type
        ttl  = rs.ttl
        data = r
      }
    ]
  ])

  # With just our list splitting technique above, records of unsupported types
  # would be silently ignored. The following two expressions ensure that
  # such records will produce an error message instead, albeit not a very
  # helpful one.
  supported_record_types = {
    A     = true
    AAAA  = true
    CNAME = true
    MX    = true
    NS    = true
    PTR   = true
    SRV   = true
    TXT   = true
  }
  check_supported_types = [
    # The index operation here will fail if one of the records has
    # an unsupported type.
    for rs in var.recordsets : local.supported_record_types[rs.type]
  ]
}
