#
# Azure Firewall
#

resource "azurerm_public_ip" "pip-fw-1" {
  name                = "pip-fw-1"
  location            = var.lab-location
  resource_group_name = var.lab-rg
  allocation_method   = "Static"
  sku                 = "Standard"

  depends_on = [
    azurerm_resource_group.resource-group
  ]
}

resource "azurerm_firewall" "firewall" {
  name                = "firewall"
  location            = var.lab-location
  resource_group_name = var.lab-rg
  sku_name            = "AZFW_VNet"
  sku_tier            = "Standard"

  ip_configuration {
    name                 = "fw-1-config"
    subnet_id            = azurerm_subnet.azurefirewallsubnet.id
    public_ip_address_id = azurerm_public_ip.pip-fw-1.id
  }

  firewall_policy_id = azurerm_firewall_policy.firewall-policy-for-transit.id

  depends_on = [
    azurerm_firewall_policy.firewall-policy-for-transit
  ]

}

resource "azurerm_firewall_policy" "firewall-policy-for-transit" {
  name                = "transit-firewall-policy"
  resource_group_name = var.lab-rg
  location            = var.lab-location
  sku                 = "Standard"

  threat_intelligence_mode = "Alert"

  # IDPS is available only for premium policies
  # intrusion_detection {
  #   mode = "Alert"
  # }

  base_policy_id = null

  dns {
    servers       = null
    proxy_enabled = false
  }

  depends_on = [
    azurerm_log_analytics_workspace.law-log-center
  ]

}

resource "azurerm_firewall_policy_rule_collection_group" "fprcg-for-transit" {
  name               = "fprcg-for-transit"
  firewall_policy_id = azurerm_firewall_policy.firewall-policy-for-transit.id
  priority           = 65000

  network_rule_collection {
    name     = "network-rule-collection-for-transit"
    priority = 200
    action   = "Allow"

  }

  application_rule_collection {
    name     = "application-rule-collection-for-transit"
    priority = 300
    action   = "Allow"


  }

  depends_on = [
    azurerm_firewall_policy.firewall-policy-for-transit
  ]

}
