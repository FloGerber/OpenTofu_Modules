module "cloud_init_leader" {
  source  = "url/cloud-init/local"
  version = "0.3.20"
  service_set = {
    docker = {
      vars = {
        role = ""
      }
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

# data "cloudinit_config" "foo" {
#   gzip          = false
#   base64_encode = false

#   part {
#     content_type = "text/cloud-config"
#     content      = <<-EOT
#     instance-id: cloud-vm
#     local-hostname: cloud-vm
#     network:
#       version: 2
#       ethernets:
#         ens192:
#           dhcp4: false
#           addresses:
#             - x.x.x.x/24
#           gateway4: x.x.x.x
#           nameservers:
#             addresses:
#               - x.x.x.x
#               - x.x.x.x
#     EOT
#   }
# }

data "cloudinit_config" "foo" {
  gzip          = false
  base64_encode = false

  part {
    content_type = "text/cloud-config"
    content      = <<-EOT
    disable_network_activation: true
    instance-id: cloud-vm
    local-hostname: cloud-vm
    network:
      version: 1
      config:
        - type: physical
          name: ens192
          subnets:
             - type: static
               address x.x.x.x/24
               gateway: x.x.x.x
        - type: nameservers
            address:
              - x.x.x.x
              - x.x.x.x
            search:
              - domain.local
    EOT
  }
}

module "example-server-linuxvm" {
  source = "../../modules/virtual_maschine"
  vmtemp = "CentOS7-xx-VM"
  # vmtemp    = "centos7-cloudinit"
  # cpu_number = 4
  # ram_size   = 8192
  instances = 1
  vmname    = "terraform-test-server-linux"
  # vmrp      = "RZ/Resources"
  vmrp = "xx/Resources"
  network = {
    "DMZ" = ["x.x.x.x"] # To use DHCP create Empty list ["",""]; You can also use a CIDR annotation;
  }
  vmgateway = "x.x.x.x"
  dc        = "domain"
  # datastore       = "x-x-x"
  datastore       = "PxURE-x-x"
  dns_server_list = ["x.x.x.x", "x.x.x.x"]
  dns_suffix_list = ["x.lxocal"]

  # data_disk = {
  #   disk1 = {
  #     size_gb                   = 30,
  #     thin_provisioned          = true,
  #     data_disk_scsi_controller = 0,
  #   }

  # }
  extra_config = {
    "guestinfo.metadata"          = base64encode(data.cloudinit_config.foo.rendered)
    "guestinfo.metadata.encoding" = "base64"
    "guestinfo.userdata"          = base64encode(module.cloud_init_leader.cloud_init_file)
    "guestinfo.userdata.encoding" = "base64"
  }
  # extra_config = base64encode(module.cloud_init_leader.cloud_init_file)
  timeout = 10

  # user-data = base64encode(module.cloud_init_leader.cloud_init_file)
  # meta-data = data.cloudinit_config.foo.rendered

}
