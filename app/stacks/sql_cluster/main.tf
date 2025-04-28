# moved {
#   from = 
#   to = 
# }

data "azurerm_key_vault" "this" {
  name                = "xxx"
  resource_group_name = "xx"
  provider            = azurerm.SharedSub
}

##############
##
## Resource Group
##
##############

module "resource_group" {
  source = "git::https://xx.xx.com/xx/_git/Terraform_Modules//modules/resource_group?ref=origin/refactor"
  # source = "../../modules/resource_group"
  naming = {
    customer_number = var.customer_number
    instance        = var.instance
  }
  environment   = var.environment
  location_name = var.location_name
  tags = {
    "Workload" = "SQL Cluster"
  }
}

##############
##
## Networking
##
##############

module "sql_vnet" {
  source = "git::https://xx.xxxx.com/xxxx/_git/Terraform_Modules//modules/network/vnet?ref=origin/refactor"
  # source              = "../../modules/network/vnet"
  resource_group_name = module.resource_group.resource_group_name
  address_space       = [var.address_space]
  environment         = var.environment
  location_name       = var.location_name
  tags = {
    "Access Layer" = "Backend"
  }
}

module "sql_subnet" {
  source = "git::https://xxx.xxx.com/xxx/_git/Terraform_Modules//modules/network/subnet?ref=origin/refactor"
  # source               = "../../modules/network/subnet"
  resource_group_name  = module.resource_group.resource_group_name
  virtual_network_name = module.sql_vnet.vnet_name

  environment = var.environment
  subnets = {
    "cluster" = {
      address_prefixes  = [var.address_space]
      service_endpoints = ["Microsoft.Storage"]
    }
  }
}

## Routing

module "default_routing" {
  source = "git::https://xxxx.xxx.com/xxxx/_git/Terraform_Modules//modules/network/route_table?ref=origin/refactor"
  # source = "../../modules/network/route_table"
  naming = {
    customer_number = var.customer_number
  }
  environment         = var.environment
  resource_group_name = module.resource_group.resource_group_name
  location_name       = var.location_name
  subnet_id           = lookup(module.sql_subnet.subnet_id, var.address_space)
}

## Peering

data "azurerm_virtual_network" "hub_cluster" {
  name                = "xx-xxx"
  resource_group_name = "xxxx"
  provider            = azurerm.SharedSub
}

data "azurerm_virtual_network" "edge_cluster" {
  name                = "xxxx-VNET"
  resource_group_name = "xxx"
  provider            = azurerm.SharedSub
}

module "peering" {
  source = "git::https://xxx.xxx.com/xxxx/_git/Terraform_Modules//modules/network/peering?ref=origin/refactor"
  #source = "../../modules/network/peering"
  providers = {
    azurerm.SharedSub = azurerm.SharedSub
  }
  environment = var.environment
  peering = {
    sqlnet-with-hub = {
      local_resource_group_name   = module.resource_group.resource_group_name
      local_virtual_network_name  = module.sql_vnet.vnet_name
      local_virtual_network_id    = module.sql_vnet.vnet_id
      remote_resource_group_name  = data.azurerm_virtual_network.hub_cluster.resource_group_name
      remote_virtual_network_name = data.azurerm_virtual_network.hub_cluster.name
      remote_virtual_network_id   = data.azurerm_virtual_network.hub_cluster.id
    }
    sqlnet-with-edge = {
      local_resource_group_name   = module.resource_group.resource_group_name
      local_virtual_network_name  = module.sql_vnet.vnet_name
      local_virtual_network_id    = module.sql_vnet.vnet_id
      remote_resource_group_name  = data.azurerm_virtual_network.edge_cluster.resource_group_name
      remote_virtual_network_name = data.azurerm_virtual_network.edge_cluster.name
      remote_virtual_network_id   = data.azurerm_virtual_network.edge_cluster.id
    }
  }
}

##############
##
## Storage Account for Wittness
##
##############

module "cloud_witness_storage_account" {
  # source = "../../modules/storage_account"
  source = "git::https://xxx.xxxx.com/xxxx/_git/Terraform_Modules//modules/storage_account?ref=origin/refactor"
  naming = {
    customer_number = var.customer_number
  }
  location_name       = var.location_name
  environment         = var.environment
  resource_group_name = module.resource_group.resource_group_name
  management_policy = {
    daily = {
      name = "Daily-Backup-Rule"
      filters = {
        blob_types = ["blockBlob"]
      }
      actions = {
        base_blob = {
          delete_after_days_since_modification_greater_than = 14
        }
      }
    }
    weekly = {
      name = "Weekly-Backup-Rule"
      filters = {
        blob_types = ["blockBlob"]
      }
      actions = {
        base_blob = {
          delete_after_days_since_modification_greater_than = 7
          delete_after_days_since_modification_greater_than = 28
        }
      }
    }
    monthly = {
      name = "Monthly-Backup-Rule"
      filters = {
        blob_types = ["blockBlob"]
      }
      actions = {
        base_blob = {
          delete_after_days_since_modification_greater_than = 1
          delete_after_days_since_modification_greater_than = 3
        }
      }
    }
  }
  tags = {
    "Details" = "Cluster Quorum Storage Account"
  }
}

module "private_endpoint" {
  source = "git::https://xx.xxx.com/xx/_git/Terraform_Modules//modules/network/private_endpoint?ref=origin/refactor"
  providers = {
    azurerm.SharedSub = azurerm.SharedSub
  }
  location_name                  = var.location_name
  environment                    = var.environment
  resource_group_name            = module.resource_group.resource_group_name
  subnet_id                      = lookup(module.sql_subnet.subnet_id, var.address_space)
  private_connection_resource_id = module.cloud_witness_storage_account.storage_account_id
  subresource_type               = "blob"
}

##############
##
## Storage Account for Cluster Storage
##
##############

module "cluster_storage_account" {
  # source = "../../modules/storage_account"
  source = "git::https://xxxx.xxx.com/xxxx/_git/Terraform_Modules//modules/storage_account?ref=origin/refactor"
  naming = {
    customer_number = var.customer_number
    instance        = "002"
  }
  #public_network_access_enabled = true
  #default_firewall_action       = "Allow"
  #allowed_cidrs                 = ["xxx.xxx.xx.x"]

  location_name            = var.location_name
  environment              = var.environment
  resource_group_name      = module.resource_group.resource_group_name
  account_tier             = "Premium"
  account_kind             = "FileStorage"
  account_replication_type = "LRS"
  file_share_authentication = {
    directory_type = "AADDS"
  }
  # file_shares = [
  #   {
  #     name        = "kunde"
  #     quota_in_gb = 100
  #   }
  # ]S
  file_share_properties_smb = {
    multichannel_enabled            = true
    version                         = ["SMB3.0", "SMB3.1.1"]
    channel_encryption_type         = ["AES-256-GCM", "AES-128-GCM"]
    kerberos_ticket_encryption_type = ["AES-256"]
  }
  tags = {
    "Details" = "Cluster Shared Storage"
  }
}

module "cluster_storage_private_endpoint" {
  source = "git::https://xxx.xxxx.com/xxx/_git/Terraform_Modules//modules/network/private_endpoint?ref=origin/refactor"
  providers = {
    azurerm.SharedSub = azurerm.SharedSub
  }
  location_name                  = var.location_name
  environment                    = var.environment
  resource_group_name            = module.resource_group.resource_group_name
  subnet_id                      = lookup(module.sql_subnet.subnet_id, var.address_space)
  private_connection_resource_id = module.cluster_storage_account.storage_account_id
  subresource_type               = "file"
}


##############
##
## Loadbalancer
##
##############

module "sql_loadbalancer" {
  source = "git::https://xxxx.xxx.com/xxxx/_git/Terraform_Modules//modules/load_balancer?ref=origin/refactor"
  # source = "../../modules/loadbalancer"
  naming = {
    customer_number = var.customer_number
  }
  location_name       = var.location_name
  environment         = var.environment
  resource_group_name = module.resource_group.resource_group_name
  sku                 = "Standard"
  frontend_ip_configurations = {
    default = {
      subnet_id                     = lookup(module.sql_subnet.subnet_id, var.address_space)
      private_ip_address_allocation = "Static"
      private_ip_address            = cidrhost(var.address_space, 5)
    }
  }
  backend_address_pool = {
    name = "SQL_Backend_Pool"
    lb_rules = {
      "SQL" = {
        backend_port       = 1433
        probe_port         = 59999
        probe_interfal     = 5
        enable_floating_ip = true
      }
    }
  }
}

resource "azurerm_network_interface_backend_address_pool_association" "this" {
  count                   = length(module.sql_vms)
  network_interface_id    = module.sql_vms[count.index].primary_network_interface_id
  ip_configuration_name   = module.sql_vms[count.index].primary_network_interface_name
  backend_address_pool_id = module.sql_loadbalancer.backend_address_pool_id
}

##############
##
## VM's
##
##############

module "sql_vms" {
  count      = 2
  is_windows = true
  source     = "git::https://xxx.xxx.com/xxxx/_git/Terraform_Modules//modules/virtual_machine?ref=origin/refactor"
  # source     = "../../modules/virtual_machine"
  naming = {
    customer_number = var.customer_number
    instance        = "00${count.index + 1}"
    name_suffix     = "sql"
  }
  location_name              = var.location_name
  environment                = var.environment
  allow_extension_operations = true
  availability_set_id        = azurerm_availability_set.sqlAS.id
  vm_size                    = var.vm_size
  # secure_boot_enabled        = false # not supported for mssql server image
  patch_assessment_mode = "ImageDefault"
  patch_mode            = "AutomaticByOS" # By platform not supported for this image
  hotpatching_enabled   = false           # not supported for sql server sku // hotpatching_enabled" is currently only supported on "2022-datacenter-azure-edition-core" or "2022-datacenter-azure-edition-core-smalldisk" image reference skus
  image_reference = {
    "publisher" = "microsoftsqlserver"
    "offer"     = "sql2019-ws2022"
    "sku"       = "standard-gen2"
    "version"   = "latest"
  }
  resource_group_name = module.resource_group.resource_group_name
  network_interfaces = {
    "primary" = {
      ip_configurations = {
        "primary" = {
          private_ip_address = cidrhost(var.address_space, 10 + count.index)
          subnet_id          = lookup(module.sql_subnet.subnet_id, var.address_space)
        }
      }
    }
  }
  tags = {
    "Function" = "SQL Cluster Node"
  }
}

resource "azurerm_availability_set" "sqlAS" {
  name                = "SQL-avs"
  location            = var.location_name
  resource_group_name = module.resource_group.resource_group_name
  managed             = true
}

module "keyvault_secrets" {
  count = length(module.sql_vms)
  providers = {
    azurerm = azurerm.SharedSub
  }
  source = "git::https://xxx.xxx.com/xxx/_git/Terraform_Modules//modules/keyvault/secrets?ref=origin/refactor"
  # source       = "../../modules/keyvault/secrets"
  key_vault_id = data.azurerm_key_vault.this.id
  secret = [{
    name         = module.sql_vms[count.index].vm_name
    value        = module.sql_vms[count.index].admin_password
    content_type = "nimda password"
    }
  ]
}

##############
##
## Domain Join & DSC's 
##
##############

resource "azurerm_virtual_machine_extension" "domain_join" {
  count                      = length(module.sql_vms)
  name                       = "${module.sql_vms[count.index].vm_name}-domainJoin"
  virtual_machine_id         = module.sql_vms[count.index].vm_id
  publisher                  = "Microsoft.Compute"
  type                       = "JsonADDomainExtension"
  type_handler_version       = "1.3"
  auto_upgrade_minor_version = true

  settings           = <<SETTINGS
                            {
                              "Name": "${var.domain_name}",
                              "OUPath": "OU=Servers,OU=xxx,DC=xxx,DC=xxx",
                              "User": "${var.domain_user_name}@${var.domain_name}",
                              "Restart": "true",
                              "Options": "3"
                            }
                        SETTINGS
  protected_settings = <<PROTECTED_SETTINGS
                            {
                              "Password": "${var.domain_user_password}" 
                            }
                        PROTECTED_SETTINGS

  lifecycle {
    ignore_changes = [settings, protected_settings]
  }
}

#Prepare the servers for Always On.  
#Adds FailOver windows components, adjusts firewall rules and adds sql service account
# resource "azurerm_virtual_machine_extension" "PrepareAlwaysOn" {
#   count                      = length(module.sql_vms)
#   name                       = "${module.sql_vms[count.index].vm_name}-PrepareAlwaysOn"
#   publisher                  = "Microsoft.Powershell"
#   virtual_machine_id         = module.sql_vms[count.index].vm_id
#   type                       = "DSC"
#   type_handler_version       = "2.83"
#   auto_upgrade_minor_version = true
#   settings                   = <<SETTINGS
#               {
#                 "WmfVersion": "latest",
#                 "modulesURL": "https://xxxxx.blob.core.windows.net/powershell-dsc/SQL_Cluster.zip",
#                 "configurationFunction": "PrepareAlwaysOnSqlServer.ps1\\PrepareAlwaysOnSqlServer",
#                 "Privacy": {
#                   "DataCollection": ""
#                 }
#               }
#               SETTINGS
# }



# #Prepare the servers for Always On.  
# #Adds FailOver windows components, joins machines to AD, adjusts firewall rules and adds sql service account
# resource "azurerm_virtual_machine_extension" "PrepareAlwaysOn" {
#   name                 = "PrepareAlwaysOn"
#   location             = var.location
#   resource_group_name  = var.resource_group_name
#   virtual_machine_name = "${local.vm1Name}-vm"
#   publisher            = "Microsoft.Powershell"
#   type                 = "DSC"
#   type_handler_version = "2.71"
#   depends_on           = [azurerm_virtual_machine_extension.CreateFileShareWitness, module.sqlvm1, azurerm_template_deployment.sqlvm]
#   settings             = <<SETTINGS
#             {
#                 "modulesURL": "https://raw.githubusercontent.com/canada-ca-terraform-modules/terraform-azurerm-sql-server-cluster/20190917.1/DSC/PrepareAlwaysOnSqlServer.ps1.zip",
#                 "configurationFunction": "PrepareAlwaysOnSqlServer.ps1\\PrepareAlwaysOnSqlServer",
#                 "properties": {
#                     "domainName": "${var.adConfig.domainName}",
#                     "sqlAlwaysOnEndpointName": "${var.sqlServerConfig.vmName}-hadr",
#                     "adminCreds": {
#                         "userName": "${var.adminUsername}",
#                         "password": "privateSettingsRef:AdminPassword"
#                     },
#                     "domainCreds": {
#                         "userName": "${var.domainUsername}",
#                         "password": "privateSettingsRef:domainPassword"
#                     },
#                     "sqlServiceCreds": {
#                         "userName": "${var.sqlServerConfig.sqlServerServiceAccountUserName}",
#                         "password": "privateSettingsRef:SqlServerServiceAccountPassword"
#                     },
#                     "NumberOfDisks": "${var.sqlServerConfig.dataDisks.numberOfSqlVMDisks}",
#                     "WorkloadType": "${var.sqlServerConfig.workloadType}",
#                     "serverOUPath": "${var.adConfig.serverOUPath}",
#                     "accountOUPath": "${var.adConfig.accountOUPath}"
#                 }
#             }
#             SETTINGS
#   protected_settings   = <<PROTECTED_SETTINGS
#          {
#       "Items": {
#                         "domainPassword": "${data.azurerm_key_vault_secret.domainAdminPasswordSecret.value}",
#                         "adminPassword": "${data.azurerm_key_vault_secret.localAdminPasswordSecret.value}",
#                         "sqlServerServiceAccountPassword": "${data.azurerm_key_vault_secret.sqlAdminPasswordSecret.value}"
#                 }
#         }
#     PROTECTED_SETTINGS
# }

# #Deploy the failover cluster
# resource "azurerm_virtual_machine_extension" "CreateFailOverCluster" {
#   name                 = "configuringAlwaysOn"
#   location             = var.location
#   resource_group_name  = var.resource_group_name
#   virtual_machine_name = "${local.vm2Name}-vm"
#   publisher            = "Microsoft.Powershell"
#   type                 = "DSC"
#   type_handler_version = "2.71"
#   depends_on           = [azurerm_virtual_machine_extension.PrepareAlwaysOn, module.sqlvm2, azurerm_template_deployment.sqlvm]
#   settings             = <<SETTINGS
#             {

#                 "modulesURL": "https://raw.githubusercontent.com/canada-ca-terraform-modules/terraform-azurerm-sql-server-cluster/20190917.1/DSC/CreateFailoverCluster.ps1.zip",
#                 "configurationFunction": "CreateFailoverCluster.ps1\\CreateFailoverCluster",
#                 "properties": {
#                     "domainName": "${var.adConfig.domainName}",
#                     "clusterName": "${local.clusterName}",
#                     "sharePath": "\\\\${local.witnessName}\\${local.sharePath}",
#                     "nodes": [
#                         "${local.vm1Name}",
#                         "${local.vm2Name}"
#                     ],
#                     "sqlAlwaysOnEndpointName": "${local.sqlAOEPName}",
#                     "sqlAlwaysOnAvailabilityGroupName": "${local.sqlAOAGName}",
#                     "sqlAlwaysOnAvailabilityGroupListenerName": "${local.sqlAOListenerName}",
#                     "SqlAlwaysOnAvailabilityGroupListenerPort": "${var.sqlServerConfig.sqlAOListenerPort}",
#                     "lbName": "${var.sqlServerConfig.sqlLBName}",
#                     "lbAddress": "${var.sqlServerConfig.sqlLBIPAddress}",
#                     "primaryReplica": "${local.vm2Name}",
#                     "secondaryReplica": "${local.vm1Name}",
#                     "dnsServerName": "${var.dnsServerName}",
#                     "adminCreds": {
#                         "userName": "${var.adminUsername}",
#                         "password": "privateSettingsRef:adminPassword"
#                     },
#                     "domainCreds": {
#                         "userName": "${var.domainUsername}",
#                         "password": "privateSettingsRef:domainPassword"
#                     },
#                     "sqlServiceCreds": {
#                         "userName": "${var.sqlServerConfig.sqlServerServiceAccountUserName}",
#                         "password": "privateSettingsRef:sqlServerServiceAccountPassword"
#                     },
#                     "SQLAuthCreds": {
#                         "userName": "sqlsa",
#                         "password": "privateSettingsRef:sqlAuthPassword"
#                     },
#                     "NumberOfDisks": "${var.sqlServerConfig.dataDisks.numberOfSqlVMDisks}",
#                     "WorkloadType": "${var.sqlServerConfig.workloadType}",
#                     "serverOUPath": "${var.adConfig.serverOUPath}",
#                     "accountOUPath": "${var.adConfig.accountOUPath}",
#                     "DatabaseNames": "${var.sqlServerConfig.sqlDatabases}",
#                     "ClusterIp": "${var.sqlServerConfig.clusterIp}"
#                 }
#             }
#             SETTINGS
#   protected_settings   = <<PROTECTED_SETTINGS
#          {
#       "Items": {
#                     "adminPassword": "${data.azurerm_key_vault_secret.localAdminPasswordSecret.value}",
#                     "domainPassword": "${data.azurerm_key_vault_secret.domainAdminPasswordSecret.value}",
#                     "sqlServerServiceAccountPassword": "${data.azurerm_key_vault_secret.sqlAdminPasswordSecret.value}",
#                     "sqlAuthPassword": "${data.azurerm_key_vault_secret.sqlAdminPasswordSecret.value}"
#                 }
#         }
#     PROTECTED_SETTINGS
# }



##############
##
## Backup
##
##############




