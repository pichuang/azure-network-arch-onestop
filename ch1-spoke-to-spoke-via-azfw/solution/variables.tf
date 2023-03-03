variable "lab-rg" {
  description = "Resource Group for this lab"
  type        = string
  default     = "rg-challenge-01"
}

variable "lab-location" {
  description = "Location for this lab"
  type        = string
  default     = "japaneast"
}

variable "tags" {
  description = "Set of tags for resources"
  type        = map(any)
  default = {
    ApplicationName = "Challenge 01"
  }
}

variable "admin_username" {
  description = "Username for the admin account"
  type        = string
  default     = "repairman"
}

variable "admin_password" {
  description = "Password for the admin account"
  type        = string
  default     = "Lyc0r!sRec0il"
  sensitive   = true
}