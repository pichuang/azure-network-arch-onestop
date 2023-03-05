

output "admin_username" {
  value = var.admin_username
}

output "admin_password" {
  sensitive = true
  value     = var.admin_password
}