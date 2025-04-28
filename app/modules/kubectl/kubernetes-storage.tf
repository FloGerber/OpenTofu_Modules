resource "azurecaf_name" "this" {
  resource_types = ["azurerm_resource_group", "azurerm_storage_account"]
  prefixes       = [join("", [substr("${var.environment}", 0, 1), var.naming.department_short_name]), join("", [var.naming.cloud_provider_short_name, var.naming.location_short_name])]
  suffixes       = var.naming.name_suffix != "" ? [var.naming.name_suffix, "${var.naming.instance}"] : ["${var.naming.instance}"]
}

resource "azurerm_resource_group" "this" {
  name     = join("-", [lookup(azurecaf_name.this.results, "azurerm_resource_group"), "k8s"])
  location = var.location_name
}

resource "azurerm_storage_account" "this" {
  name                     = join("", [lookup(azurecaf_name.this.results, "azurerm_storage_account"), "k8s"])
  resource_group_name      = azurerm_resource_group.this.name
  location                 = azurerm_resource_group.this.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "kubernetes_storage_class" "this" {
  metadata {
    name = var.storage_class_name
  }
  storage_provisioner = "file.csi.azure.com"
  reclaim_policy      = "Retain"
  parameters = {
    skuName        = var.sku_name
    location       = var.location_name
    storageAccount = azurerm_storage_account.this.name
    resourceGroup  = azurerm_resource_group.this.name
  }
  allow_volume_expansion = true
  volume_binding_mode    = "Immediate"
  mount_options = [
    "file_mode=0777",
    "dir_mode=0777",
    "mfsymlinks",
    "nobrl",
    "cache=strict", # https://linux.die.net/man/8/mount.cifs
    "nosharesock",  # reduce probability of reconnect race
    "actimeo=30"    # reduce latency for metadata-heavy workload
  ]
}
