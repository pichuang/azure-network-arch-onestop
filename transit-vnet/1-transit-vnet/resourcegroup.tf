resource "azurerm_resource_group" "resource-group" {
  location = var.lab-location
  name     = var.lab-rg
}

resource "time_sleep" "wait_for_resource_group" {
  create_duration = "10s"

  depends_on = [azurerm_resource_group.resource-group]
}