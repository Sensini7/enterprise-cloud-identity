## Modifying Alerts requires disabling the Azure Policy preventing changes to the logging resources
## This is done by:
## 1. Browsing to Policy Assignments in Azure Policy
## 2. Searching for the policy named "Block Deletion of ICAM PreventDestroy Resources"
## 3. Supplying the resource groups to exclude from the policy (i.e. EZD-icam-mgmt-monitoring-rg)
## 4. Performing the change
## 5. Re-enabling the policy after the change is complete (this can be done via Terraform)

locals {
  azure_resources_alert_query = var.is_azure_gov ? local.azure_resources_query_gov : local.azure_resources_query_com
  azure_resources_query_gov   = "AzureActivity | where ResourceGroup in ('EZD-ICAM-MGMT-USGOVVIRGINIA-EMERGENCY-ACCOUNTS-RG', 'EZD-ICAM-MGMT-MONITORING-RG')"
  azure_resources_query_com   = "${local.azure_resources_query_gov} | where OperationNameValue == 'MICROSOFT.OPERATIONALINSIGHTS/WORKSPACES/SHAREDKEYS/ACTION' and Caller != '${var.deployment_enterprise_app_object_id}'"
  prod_pipeline_audit_query   = "ProductionPipeline_CL"

  ## Resources that use dynamic or count should have their names hardcoded
  prod_audit_resource_name      = "apr-${var.ci_environment_name}-deployment-audit"
  alerts_group_name             = "${var.customer_name}-${var.project_name}-${var.environment_name}-monitoring-action-group-azure-resources"
  alert_emergency_accounts_name = "apr-${var.ci_environment_name}-emergency-account-user-signin"
  alert_azure_resources_name    = "apr-${var.ci_environment_name}-azure-resources-alert"

  alert_resource_names = [
    local.alerts_group_name,
    local.prod_audit_resource_name,
    local.alert_emergency_accounts_name,
    local.alert_azure_resources_name
  ]
}

resource "azurerm_monitor_action_group" "alerts-group" {
  provider            = azurerm.logging
  name                = local.alerts_group_name
  resource_group_name = azurerm_resource_group.rg-monitoring.name
  short_name          = "az-resources"
  dynamic "email_receiver" {
    for_each = var.icam_alerts_action_group
    content {
      name                    = email_receiver.value["name"]
      email_address           = email_receiver.value["email"]
      use_common_alert_schema = true
    }
  }

  tags = {
    SYSTEM     = var.system_tag
    CostCenter = var.log_cost_center
    Agency     = var.log_agency
  }
}

resource "azurerm_monitor_scheduled_query_rules_alert_v2" "apr-monitoring-emergency-accounts-alert" {
  provider            = azurerm.logging
  name                = local.alert_emergency_accounts_name
  resource_group_name = azurerm_resource_group.rg-monitoring.name
  location            = azurerm_resource_group.rg-monitoring.location
  description         = "An emergency account was signed into in ${var.ci_environment_name}"

  evaluation_frequency = "PT10M"
  scopes               = [azurerm_log_analytics_workspace.law.id]
  severity             = 0
  window_duration      = "PT10M"

  skip_query_validation = true

  criteria {
    query                   = "SigninLogs | where UserDisplayName contains '${var.breakglass_display_name}' | project UserDisplayName, CreatedDateTime, UserId, ResourceId"
    time_aggregation_method = "Count"
    threshold               = 0
    operator                = "GreaterThan"
    resource_id_column      = "ResourceId"
  }

  action {
    action_groups = [azurerm_monitor_action_group.alerts-group.id]
  }

  tags = {
    SYSTEM     = var.system_tag
    CostCenter = var.log_cost_center
    Agency     = var.log_agency
  }
}

resource "azurerm_monitor_scheduled_query_rules_alert_v2" "apr-monitoring-azure-resources-alert" {
  provider            = azurerm.logging
  name                = local.alert_azure_resources_name
  resource_group_name = azurerm_resource_group.rg-monitoring.name
  location            = azurerm_resource_group.rg-monitoring.location
  description         = "An ICAM labeled Azure Resource was modified in ${var.ci_environment_name}"

  evaluation_frequency = "PT10M"
  scopes               = [azurerm_log_analytics_workspace.law.id]
  severity             = 0
  window_duration      = "PT10M"

  skip_query_validation = true

  criteria {
    query                   = local.azure_resources_alert_query
    time_aggregation_method = "Count"
    threshold               = 0
    operator                = "GreaterThan"
    resource_id_column      = "_ResourceId"
  }

  action {
    action_groups = [azurerm_monitor_action_group.alerts-group.id]
  }

  tags = {
    SYSTEM     = var.system_tag
    CostCenter = var.log_cost_center
    Agency     = var.log_agency
  }
}

resource "azurerm_monitor_scheduled_query_rules_alert_v2" "apr-monitoring-prod-deployments" {
  count               = var.environment_name == "prd" ? 1 : 0
  provider            = azurerm.logging
  name                = local.prod_audit_resource_name
  resource_group_name = azurerm_resource_group.rg-monitoring.name
  location            = azurerm_resource_group.rg-monitoring.location
  description         = "A Production Deployment to ${var.ci_environment_name} has occurred."

  evaluation_frequency = "PT10M"
  scopes               = [azurerm_log_analytics_workspace.law.id]
  severity             = 0
  window_duration      = "PT10M"

  skip_query_validation = true

  criteria {
    query                   = local.prod_pipeline_audit_query
    time_aggregation_method = "Count"
    threshold               = 0
    operator                = "GreaterThan"
  }

  action {
    action_groups = [azurerm_monitor_action_group.alerts-group.id]
  }

  tags = {
    SYSTEM     = var.system_tag
    CostCenter = var.log_cost_center
    Agency     = var.log_agency
  }
}
