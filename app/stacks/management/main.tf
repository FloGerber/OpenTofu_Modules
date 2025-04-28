resource "random_password" "this" {
  length           = 34
  override_special = "_"
}

module "cloud_init_base" {
  source  = "devops/cloud-init/local"
  version = "0.3.2"
  service_set = {
    proxy = {
      vars = {
        proxyuser = {
          admina = random_password.this.result
        }
      }
    }
  }
  users = {
    "terraform" = {
      ssh_key = sensitive(file("~/.ssh/ssh_key.pub"))
    }
  }
}

module "cloud_init_bind" {
  #  source = "git:://infrastructure/cloud-init.git"
  source  = "//local"
  version = "0.3.2"
  service_set = {
    bind = {
      vars = {
        virtual_network_range = "${var.virtual_network_range}"
      }
    }
  }
}

module "management_subnet" {
  source = "../../modules/network/subnet"
  naming = {
    name_suffix               = "mgmt"
    cloud_provider_short_name = lookup(local.cloud_provider_short_name, "azure")
    department_short_name     = lookup(local.department_short_name)
    instance                  = var.instance
    location_short_name       = lookup(local.location_short_name, var.location_name)
  }
  resource_group_name  = var.resource_group_name
  virtual_network_name = var.default_virtual_network_name #azurerm_virtual_network.this.name #var.default_virtual_network_name
  address_prefixes     = var.address_prefixes
  # name                                           = "management-${var.instance}" # Just define some identifier, it will be automaticaly pre/suffixed.
  environment                                    = var.environment
  enforce_private_link_endpoint_network_policies = true
}

module "management_security_group" {
  naming = {
    name_suffix               = "mgmt"
    cloud_provider_short_name = lookup(local.cloud_provider_short_name, "azure")
    department_short_name     = lookup(local.department_short_name)
    instance                  = var.instance
    location_short_name       = lookup(local.location_short_name, var.location_name)
  }
  source              = "../../modules/network/security_group"
  location_name       = var.location_name
  resource_group_name = var.resource_group_name
  environment         = var.environment
  security_rules = [
    {
      name                       = "DNS INBOUND",
      priority                   = "101"
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Udp"
      source_port_range          = "*"
      destination_port_range     = "53"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    },
    {
      name                       = "DNS OUTBOUND",
      priority                   = "102"
      direction                  = "Outbound"
      access                     = "Allow"
      protocol                   = "Udp"
      source_port_range          = "*"
      destination_port_range     = "53"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    },
    {
      name                       = "SSH External and VIA VPN",
      priority                   = "103"
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "22"
      source_address_prefixes    = ["x.x.x.x/16", "x.x.x.x", "x.x.x.x", "x.x.x.x"]
      destination_address_prefix = "*"
    }
  ]
}

module "management_subnet_security_group_association" {
  source            = "../../modules/network/association"
  security_group_id = module.management_security_group.security_group_id
  subnet_id         = module.management_subnet.subnet_id
}

module "bind_server" {
  source = "../../modules/virtual_machine"
  naming = {
    name_suffix               = "bind"
    cloud_provider_short_name = lookup(local.cloud_provider_short_name, "azure")
    department_short_name     = lookup(local.department_short_name)
    instance                  = var.instance
    location_short_name       = lookup(local.location_short_name, var.location_name)
  }
  location_name       = var.location_name
  resource_group_name = var.resource_group_name
  environment         = var.environment
  #subnet_id           = module.management_subnet.subnet_id
  vm_size    = "Standard_B1s"
  public_key = var.admina_rsa
  image_reference = {
    publisher = "Debian"
    offer     = "debian-11"
    sku       = "11-gen2"
    version   = "latest"
  }
  network_interfaces = [
    {
      name                          = "" # Required, but you can just add "" to let the manifest generate it, it will use the module name
      enable_ip_forwarding          = false
      enable_accelerated_networking = false
      ip_configurations = [
        {
          name                          = "" # Required, but you can just add "" to let the manifest generate it, it will use the module name
          subnet_id                     = tostring(module.management_subnet.subnet_id)
          private_ip_address_allocation = "Static"
          private_ip_address            = var.private_ip_address
          public_ip_address_id          = ""
          primary                       = true
        }
      ]
    }
  ]
  custom_data = base64encode(module.cloud_init_bind.cloud_init_file)
}

# resource "azurecaf_name" "this" {
#   resource_types = "azurerm_public_ip"
#   prefixes       = [join("", [substr("${var.environment}", 0, 1), var.naming.department_short_name]), join("", [var.naming.cloud_provider_short_name, var.naming.location_short_name])]
#   suffixes       = var.naming.name_suffix != "" ? [var.naming.name_suffix, "${var.naming.instance}"] : ["${var.naming.instance}"]
# }

resource "azurerm_public_ip" "this" {
  name                = "${var.environment}-jump-host-ip"
  resource_group_name = var.resource_group_name
  location            = var.location_name
  sku                 = "Standard"
  allocation_method   = "Static"
  tags                = var.tags
}

module "jump_host" {
  source = "../../modules/virtual_machine"
  naming = {
    name_suffix               = "jump"
    cloud_provider_short_name = lookup(local.cloud_provider_short_name, "azure")
    department_short_name     = lookup(local.department_short_name)
    instance                  = var.instance
    location_short_name       = lookup(local.location_short_name, var.location_name)
  }
  location_name       = var.location_name
  resource_group_name = var.resource_group_name
  environment         = var.environment
  vm_size             = "Standard_B1ls" #"Standard_D2ds_v4" 
  public_key          = var.admina_rsa
  image_reference = {
    publisher = "Debian"
    offer     = "debian-11"
    sku       = "11-gen2"
    version   = "latest"
  }
  network_interfaces = [
    {
      name                          = "" # Required, but you can just add "" to let the manifest generate it, it will use the module name
      enable_ip_forwarding          = false
      enable_accelerated_networking = false
      ip_configurations = [
        {
          name                          = "" # Required, but you can just add "" to let the manifest generate it, it will use the module name
          subnet_id                     = tostring(module.management_subnet.subnet_id)
          private_ip_address_allocation = "Dynamic"
          private_ip_address            = ""
          public_ip_address_id          = azurerm_public_ip.this.id
          primary                       = true
        }
      ]
    }
  ]
  custom_data = base64encode(module.cloud_init_base.cloud_init_file)

  depends_on = [
    module.bind_server
  ]
}
