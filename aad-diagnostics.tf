moved {
  from = azurerm_monitor_aad_diagnostic_setting.example
  to   = azurerm_monitor_aad_diagnostic_setting.entra-diagnostics
}
resource "azurerm_monitor_aad_diagnostic_setting" "entra-diagnostics" {
  provider                   = azurerm.security
  name                       = "entra-diagnostics"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id

  enabled_log {
    category = "SignInLogs"
    retention_policy {
      enabled = false
    }
  }
  enabled_log {
    category = "NonInteractiveUserSignInLogs"
    retention_policy {
      enabled = false
    }
  }
  enabled_log {
    category = "AuditLogs"
    retention_policy {
      enabled = false
    }
  }
  enabled_log {
    category = "ServicePrincipalSignInLogs"
    retention_policy {
      enabled = false
    }
  }
  enabled_log {
    category = "ManagedIdentitySignInLogs"
    retention_policy {
      enabled = false
    }
  }
  enabled_log {
    category = "ProvisioningLogs"
    retention_policy {
      enabled = false
    }
  }
  enabled_log {
    category = "ADFSSignInLogs"
    retention_policy {
      enabled = false
    }
  }
  enabled_log {
    category = "RiskyUsers"
    retention_policy {
      enabled = false
    }
  }
  enabled_log {
    category = "UserRiskEvents"
    retention_policy {
      enabled = false
    }
  }
  enabled_log {
    category = "RiskyServicePrincipals"
    retention_policy {
      enabled = false
    }
  }
  enabled_log {
    category = "ServicePrincipalRiskEvents"
    retention_policy {
      enabled = false
    }
  }
  enabled_log {
    category = "MicrosoftGraphActivityLogs"
    retention_policy {
      enabled = false
    }
  }

  ## The following are not supported in GovCloud region
  dynamic "enabled_log" {
    for_each = var.is_azure_gov ? [] : [1]
    content {
      category = "EnrichedOffice365AuditLogs"
      retention_policy {
        enabled = false
      }
    }
  }
  dynamic "enabled_log" {
    for_each = var.is_azure_gov ? [] : [1]
    content {
      category = "RemoteNetworkHealthLogs"
      retention_policy {
        enabled = false
      }
    }
  }
  dynamic "enabled_log" {
    for_each = var.is_azure_gov ? [] : [1]
    content {
      category = "NetworkAccessTrafficLogs"
      retention_policy {
        enabled = false
      }
    }
  }
}
