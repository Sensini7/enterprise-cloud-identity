resource "azurerm_monitor_diagnostic_setting" "diag-azure-activity-logging" {
  provider                   = azurerm.logging
  name                       = "diag-azure-activity"
  target_resource_id         = "/subscriptions/${var.management_logging_subscription_id}"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id

  enabled_log {
    category = "Administrative"
  }
  enabled_log {
    category = "Security"
  }
  enabled_log {
    category = "ServiceHealth"
  }
  enabled_log {
    category = "Alert"
  }
  enabled_log {
    category = "Recommendation"
  }
  enabled_log {
    category = "Policy"
  }
  enabled_log {
    category = "Autoscale"
  }
  enabled_log {
    category = "ResourceHealth"
  }
}

resource "azurerm_monitor_diagnostic_setting" "diag-azure-activity-security" {
  provider                   = azurerm.logging
  count                      = var.management_logging_subscription_id == var.management_security_subscription_id ? 0 : 1
  name                       = "diag-azure-activity"
  target_resource_id         = "/subscriptions/${var.management_security_subscription_id}"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id

  enabled_log {
    category = "Administrative"
  }
  enabled_log {
    category = "Security"
  }
  enabled_log {
    category = "ServiceHealth"
  }
  enabled_log {
    category = "Alert"
  }
  enabled_log {
    category = "Recommendation"
  }
  enabled_log {
    category = "Policy"
  }
  enabled_log {
    category = "Autoscale"
  }
  enabled_log {
    category = "ResourceHealth"
  }
}
