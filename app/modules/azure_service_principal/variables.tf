variable "environment" {
  type        = string
  description = "Input the environment"
}

variable "name" {
  type        = string
  description = "Input the name of the Service Principal"
}

variable "description" {
  type        = string
  description = "Input a Description for the Service Principal"
  default     = "Default Value / Please set a Proper descriptions"
}

variable "password_rotation_interval_days" {
  type        = number
  description = "Input the Day when the Service Principals Password should be rotated"
  default     = 30
}
