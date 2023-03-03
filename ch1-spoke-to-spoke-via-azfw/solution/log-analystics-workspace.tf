#
# Log Analytics Workspace
#

resource "azurerm_log_analytics_workspace" "law-log-center" {

  name                       = "law-log-center"
  location                   = var.lab-location
  resource_group_name        = var.lab-rg
  sku                        = "PerGB2018"
  retention_in_days          = 30 # 7 (Free Tier Only), 30 ~ 730
  daily_quota_gb             = -1
  internet_ingestion_enabled = true
  internet_query_enabled     = true
  # reservation_capacity_in_gb_per_day = 100

}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting

resource "azurerm_monitor_diagnostic_setting" "diagnostic-for-firewall" {
  name                       = "diagnostic-for-firewall"
  target_resource_id         = azurerm_firewall.firewall.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.law-log-center.id

  # Dedicated or AzureDiagnostics
  log_analytics_destination_type = "AzureDiagnostics"

  # enabled_log {
  #   category = "allLogs"

  #   retention_policy {
  #     enabled = false
  #   }
  # }

  # Log Source: https://learn.microsoft.com/en-us/azure/azure-monitor/essentials/resource-logs-categories

  log {
    enabled  = true
    category = "AzureFirewallNetworkRule"

    retention_policy {
      enabled = true
    }
  }

  log {
    enabled  = true
    category = "AZFWNetworkRule"

    retention_policy {
      enabled = true
    }
  }

  metric {
    category = "AllMetrics"

    retention_policy {
      enabled = true
    }
  }
}