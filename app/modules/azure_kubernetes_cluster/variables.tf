variable "naming" {
  type = object({
    instance                  = string
    name_suffix               = string
    department_short_name     = string
    cloud_provider_short_name = string
    location_short_name       = string
  })
  validation {
    condition     = can(regex("^[0-9]{2}[1-9]$", var.naming.instance))
    error_message = "The instance number must be a number between 001 and 999!"
  }
  validation {
    condition     = can(regex("^[a-z]{0,6}$", var.naming.name_suffix))
    error_message = "The name suffix must be a lowercase string between 0 and 6 characters!"
  }
  description = "Input the naming parameters for autogenerator, if not fully provided it will use default and random values"
  default = {
    instance                  = "001"
    name_suffix               = ""
    department_short_name     = "rd"
    cloud_provider_short_name = "az"
    location_short_name       = "gwc"
  }
}

variable "k8s_version" {
  type        = string
  default     = "1.21.9"
  description = "Kubernetes version"
}

variable "min_node_count" {
  type        = number
  default     = 2
  description = "Kubernetes min nodes"
}

variable "max_node_count" {
  type        = number
  default     = 5
  description = "Kubernetes max nodes"
}

variable "node_type" {
  type        = string
  default     = "Standard_F2s_v2"
  description = "VM type for nodes"
}

variable "node_disk_size" {
  type        = number
  default     = 30
  description = "Disk size for the node"
}

variable "location_name" {
  type        = string
  description = "location of cluster"
}

variable "resource_group_name" {
  type        = string
  description = "resource group for cluster"
}

variable "subnet_id" {
  type        = string
  description = "ID of the subnet the cluster should be integrated in"
}

variable "environment" {
  type        = string
  description = "Input the environment"
}

variable "service_principal_client_id" {
  type        = string
  description = "application_id of service principal associated with cluster"
}

variable "service_principal_client_secret" {
  type        = string
  description = "secret of service principal associated with cluster"
  sensitive   = true
}

variable "application_gateway_id" {
  type        = string
  description = "ID of the Azure Application Gateway to be used as ingress controller"
}

variable "service_cidr" {
  type        = string
  description = "Service CIDR of Network"
}

variable "dns_service_ip" {
  type        = string
  description = "Service IP of Kubernetes DNS"
}

variable "tags" {
  description = "The tags to associate with your network and subnets."
  type        = map(string)

  default = {
    terraform = true
  }
}

variable "private_dns_zone_id" {
  type        = string
  description = "Input the Private DNS Zone ID"
  default     = "System"
}

variable "private_cluster_enabled" {
  type        = bool
  description = "Input the true to create a private cluster"
  default     = false
}

variable "public_network_access_enabled" {
  type        = bool
  description = "Input the false to disable public network access"
  default     = true
}

variable "role_based_access_control" {
  type        = bool
  description = "Input the true if you want to enable RBAC on the cluster"
  default     = false
}

variable "local_account_disabled" {
  type        = bool
  description = "Input the true if you want to dissable the local account, you will only be able to access the cluster with AAD Credentials"
  default     = false
}

variable "open_service_mesh_enabled" {
  type        = bool
  description = "Input the true to enable openservicemesh within aks"
  default     = true
}
