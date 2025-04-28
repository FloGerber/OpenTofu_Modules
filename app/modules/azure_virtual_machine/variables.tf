variable "naming" {
  type = object({
    instance                  = string
    name_suffix               = string
    department_short_name     = string
    cloud_provider_short_name = string
    location_short_name       = string
  })
  # validation {
  #   condition     = can(regex("^[0-9]{1-3}$", var.naming.instance))
  #   error_message = "The instance number must be a number between 001 and 999!"
  # }
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

variable "location_name" {
  type        = string
  description = "Input the Location Name"
}

variable "resource_group_name" {
  type        = string
  description = "Input the Resource Group Name"
  default     = "global"
}

variable "environment" {
  type        = string
  description = "Input the environment"
}

variable "tags" {
  description = "The tags to associate with your network and subnets."
  type        = map(string)

  default = {
    terraform  = true
    terraspace = true
  }
}

variable "network_interfaces" {
  type = list(object({
    name                          = string
    enable_ip_forwarding          = bool
    enable_accelerated_networking = bool

    ip_configurations = list(object({
      name                          = string
      subnet_id                     = string
      private_ip_address_allocation = string
      public_ip_address_id          = string
      private_ip_address            = string
      primary                       = bool
    }))

  }))
  description = "Input the List of Network Interface objects"
}

variable "is_windows" {
  type        = bool
  description = "Input the true if you want to create a windows virtual maschiene"
  default     = false
}

variable "vm_size" {
  type        = string
  description = "Input the Size for the VM"
  default     = "Standard_D2s_v3"
}

variable "availability_set_enabled" {
  type        = bool
  description = "Input the true if you want to enable availability set, this will create a standby maschine for your vm / also doubles the costs!"
  default     = false
}

variable "image_reference" {
  type        = map(string)
  description = "Input the Image Reference for on of the public Images within Azure, you can also set and \"image_id\" for a custom image"
  default = {
    publisher = "Debian"
    offer     = "debian-11"
    sku       = "11-gen2"
    version   = "latest"
  }
}

variable "os_caching" {
  type        = string
  description = "Input the Type of OS Caching you want to use"
  default     = "None"
  validation {
    condition     = var.os_caching == "None" || var.os_caching == "ReadOnly" || var.os_caching == "ReadWrite"
    error_message = "No valide OS Chaching Type was selected."
  }
}

variable "storage_account_type" {
  type        = string
  description = "Input the Storage Account type for the OS Disk"
  default     = "StandardSSD_LRS"
  validation {
    condition     = var.storage_account_type == "Standard_LRS" || var.storage_account_type == "StandardSSD_LRS" || var.storage_account_type == "Premium_LRS"
    error_message = "No valide Storage Account Type was selected."
  }
}

variable "admin_username" {
  type        = string
  description = "Input the admin username you want for the VM"
  default     = "admina"
}

variable "public_key" {
  type        = string
  description = "Input the Public Key for the Admin Account, only RSA Keys are allowed :("
}

variable "disable_password_authentication" {
  type        = bool
  description = "Input true if you want to disable password authentication"
  default     = true
}

variable "encryption_at_host_enabled" {
  type        = bool
  description = "Input true if you want to encrypte the whoole Maschine including /tmp"
  default     = false
}

variable "secure_boot_enabled" {
  type        = bool
  description = "Input true if you want to enable secure boot for your system "
  default     = true
}

variable "custom_data" {
  type        = string
  description = "Input the Base64 encodet Custom / Cloud-init Skript"
  nullable    = true
  default     = null
}

variable "linux_cloud_init_contents" {
  description = "Linux VMs list, sample : https://docs.microsoft.com/azure/virtual-machines/linux/tutorial-automate-vm-deployment?WT.mc_id=AZ-MVP-5003548"
  type        = any
  default     = {}
}

variable "availability_set_id" {
  type        = string
  description = "Id of the availability set"
  default     = ""
}

variable "command_to_execute" {
  type        = string
  description = "Input the command you want to execute on the server after provisioning"
  default     = "echo 'Nothing to do'"
  sensitive   = false
}
