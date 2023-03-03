#
# Azure Firewall
#

resource "azurerm_public_ip" "pip-fw-1" {
  name                = "pip-fw-1"
  location            = var.lab-location
  resource_group_name = var.lab-rg
  allocation_method   = "Static"
  sku                 = "Standard"
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

  insights {
    enabled                            = true
    default_log_analytics_workspace_id = azurerm_log_analytics_workspace.law-log-center.id
    log_analytics_workspace {
      id                = azurerm_log_analytics_workspace.law-log-center.id
      firewall_location = var.lab-location
    }
    retention_in_days = 7
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

    rule {
      name                  = "network-rule-icmp-any-to-any"
      protocols             = ["ICMP"]
      source_addresses      = ["*"]
      destination_addresses = ["*"]
      destination_ports     = ["*"]
    }
  }

  application_rule_collection {
    name     = "application-rule-collection-for-transit"
    priority = 300
    action   = "Allow"

    rule {
      name                  = "application-rule-http-any-to-os-repository"
      protocols {
        type = "Http"
        port = 80
      }
      source_addresses      = ["*"]
      destination_fqdns     = ["azure.archive.ubuntu.com"]
    }

    rule {
      name                  = "application-rule-https-any-to-github"
      protocols {
        type = "Https"
        port = 443
      }
      source_addresses      = ["*"]
      destination_fqdns     = ["github.com"]
    }

    rule {
      name                  = "application-rule-https-any-to-ifconfig"
      protocols {
        type = "Https"
        port = 443
      }

      protocols {
        type = "Http"
        port = 80
      }

      source_addresses      = ["*"]
      destination_fqdns     = ["ifconfig.me"]
    }
  }

  depends_on = [
    azurerm_firewall_policy.firewall-policy-for-transit
  ]

}
