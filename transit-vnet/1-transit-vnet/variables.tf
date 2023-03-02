variable "lab-rg" {
  description = "Resource Group for this lab"
  type        = string
  default     = "rg-transit-vnet"
}

variable "lab-location" {
  description = "Location for this lab"
  type        = string
  default     = "eastus"
}

variable "tags" {
  description = "Set of tags for resources"
  type        = map(any)
  default = {
    ApplicationName = "transit-vnet"
  }
}

variable "admin_username" {
    description = "Username for the admin account"
    type = string
    default = "repairman"
}

variable "admin_password" {
    description = "Password for the admin account"
    type = string
    default = "Lyc0r!sRec0il"
    sensitive = true
}