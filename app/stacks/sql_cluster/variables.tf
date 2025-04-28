variable "location_name" {
  type        = string
  description = "Input the Location Name"
}

variable "environment" {
  type        = string
  description = "Input the environment"
}

variable "instance" {
  type        = string
  description = "Input the Instance for the resource"
}

variable "subscription_id" {
  type        = string
  description = "Input Subscription ID"
}

variable "customer_number" {
  type        = string
  description = "Input the Customer Number"
}

variable "address_space" {
  type        = string
  description = "Input the IP Adress Space for the Customer"
}

variable "domain_name" {
  type        = string
  description = "Input the Domain where the SQL Cluster should be joined"
}

variable "domain_user_name" {
  type        = string
  description = "Input the Service User for Domain Join"
}

variable "domain_user_password" {
  type = string
  description = "Input the Service User Password for Domain Join"
  sensitive = true
}

variable "vm_size" {
  type = string
  description = "Input the VM Size"
}