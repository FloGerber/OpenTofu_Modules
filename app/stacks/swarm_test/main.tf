locals {
  manager = ["x.x.x.x", "x.x.x.x", "x.x.x.x"]
  worker = ["x.x.x.x", "x.x.x.x", "x.x.x.x"]
}

module "cloud_init_leader" {
  source  = "/cloud-init/local"
  version = "0.3.20"
  service_set = {
    docker = {
      vars = {
        role = ""
      }
    }
  }
  users = {
    "terraform" = {
      ssh_key = sensitive(file("~/.ssh/ssh_key.pub"))
      groups  = ["docker", ]
      sudo    = true
    }
  }
  repository = {
    "docker" = {
      type = "yum"
      uri  = "https://download.docker.com/linux/centos/$releasever/$basearch/stable"
      key  = "https://download.docker.com/linux/centos/gpg"
    }
    "epel" = {
      type = "yum"
      uri  = "http://download.fedoraproject.org/pub/epel/7/$basearch"
      key  = "https://mirror.dogado.de/fedora-epel/RPM-GPG-KEY-EPEL-7"
    }
  }
}

module "cloud_init_worker" {
  source  = "/cloud-init/local"
  version = "0.3.20"
  service_set = {
    docker = {
      vars = {
        role = ""
      }
    }
  }
  users = {
    "terraform" = {
      ssh_key = sensitive(file("~/.ssh/ssh_key.pub"))
      groups  = ["docker", ]
      sudo    = true
    }
  }
  repository = {
    "docker" = {
      type = "yum"
      uri  = "https://download.docker.com/linux/centos/$releasever/$basearch/stable"
      key  = "https://download.docker.com/linux/centos/gpg"
    }
    "epel" = {
      type = "yum"
      uri  = "http://download.fedoraproject.org/pub/epel/7/$basearch"
      key  = "https://mirror.dogado.de/fedora-epel/RPM-GPG-KEY-EPEL-7"
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
      source_address_prefixes    = ["x.x.x.x/16", "x.x.x.x"]
      destination_address_prefix = "*"
    },
    {
      name                       = "docker swarm join inbound",
      priority                   = "104"
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "2377"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    },
    {
      name                       = "docker swarm join outbound",
      priority                   = "104"
      direction                  = "Outbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "2377"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    }
  ]
}

module "management_subnet_security_group_association" {
  source            = "../../modules/network/association"
  security_group_id = module.management_security_group.security_group_id
  subnet_id         = module.management_subnet.subnet_id
}

resource "azurerm_public_ip" "this" {
  count               = length(local.manager)
  name                = "${var.environment}-jump-host-ip-${count.index}"
  resource_group_name = var.resource_group_name
  location            = var.location_name
  sku                 = "Standard"
  allocation_method   = "Static"
  tags                = var.tags
}

module "swarm_manager" {

  count  = length(local.manager)
  source = "../../modules/virtual_machine"
  naming = {
    name_suffix               = "master"
    cloud_provider_short_name = lookup(local.cloud_provider_short_name, "azure")
    department_short_name     = lookup(local.department_short_name)
    instance                  = tostring("${count.index}")
    location_short_name       = lookup(local.location_short_name, var.location_name)
  }
  location_name       = var.location_name
  resource_group_name = var.resource_group_name
  environment         = var.environment
  secure_boot_enabled = false
  vm_size             = "Standard_D2ds_v4"
  public_key          = var.admina_rsa
  image_reference = {
    publisher = "OpenLogic"
    offer     = "CentOS"
    sku       = "7_9-gen2"
    version   = "latest"
  }
  network_interfaces = [
    {
      name                          = "" # Required, but you can just add "" to let the manifest generate it, it will use the module name
      enable_ip_forwarding          = true
      enable_accelerated_networking = false
      ip_configurations = [
        {
          name                          = "" # Required, but you can just add "" to let the manifest generate it, it will use the module name
          subnet_id                     = tostring(module.management_subnet.subnet_id)
          private_ip_address_allocation = "Static"
          private_ip_address            = local.manager[count.index]
          public_ip_address_id          = azurerm_public_ip.this[count.index].id
          primary                       = true
        }
      ]
    }
  ]
  custom_data = base64encode(module.cloud_init_leader.cloud_init_file)

  command_to_execute = "${count.index}" == 0 ? "until sudo cloud-init status --wait > /dev/null 2>&1; do sleep 10; done && sudo docker swarm init" : "echo 'Manager ${count.index} now joining' && until sudo cloud-init status --wait > /dev/null 2>&1; do sleep 10; done && sleep 120 && jointoken=$(ssh -oStrictHostKeyChecking=no terraform@${local.manager[0]} 'sudo docker swarm join-token manager -q') && sudo docker swarm join --token $jointoken ${local.manager[0]}:2377"

}


module "swarm_worker" {

  count  = length(local.worker)
  source = "../../modules/virtual_machine"
  naming = {
    name_suffix               = "worker"
    cloud_provider_short_name = lookup(local.cloud_provider_short_name, "azure")
    department_short_name     = lookup(local.department_short_name, "infrastructure_opertations")
    instance                  = tostring("${count.index}")
    location_short_name       = lookup(local.location_short_name, var.location_name)
  }
  location_name       = var.location_name
  resource_group_name = var.resource_group_name
  environment         = var.environment
  secure_boot_enabled = false
  vm_size             = "Standard_B2s"
  public_key          = var.admina_rsa
  image_reference = {
    publisher = "OpenLogic"
    offer     = "CentOS"
    sku       = "7_9-gen2"
    version   = "latest"
  }
  network_interfaces = [
    {
      name                          = "" # Required, but you can just add "" to let the manifest generate it, it will use the module name
      enable_ip_forwarding          = true
      enable_accelerated_networking = false
      ip_configurations = [
        {
          name                          = "" # Required, but you can just add "" to let the manifest generate it, it will use the module name
          subnet_id                     = tostring(module.management_subnet.subnet_id)
          private_ip_address_allocation = "Static"
          private_ip_address            = local.worker[count.index]
          public_ip_address_id          = ""
          primary                       = true
        }
      ]
    }
  ]
  custom_data = base64encode(module.cloud_init_worker.cloud_init_file)

  command_to_execute = "echo 'Worker ${count.index} now joining' && until sudo cloud-init status --wait > /dev/null 2>&1; do sleep 10; done && sleep 120 && jointoken=$(ssh -oStrictHostKeyChecking=no terraform@${local.manager[0]} 'sudo docker swarm join-token worker -q') && sudo docker swarm join --token $jointoken ${local.manager[0]}:2377"

  depends_on = [
    module.swarm_manager
  ]
}
