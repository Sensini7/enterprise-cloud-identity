## Requires Entra Security Defaults to be disabled. 
## The workflow "Entra: Initialize Baseline" must first be run. See `ps-disable-security-defaults.yml`
## If Security Defaults are enabled, Terraform will fail to create the Conditional Access Policies.
module "conditional_access_policy" {
  source = "git@github.com:Sensini7/EntraID-800-53-Terraform-Modules.git//modules/conditional_access_policies?ref=main"

  is_azure_gov = var.is_azure_gov

  excluded_groups = [
    azuread_group.excluded_from_conditional_access_group.id,
    azuread_group.emergency-access-group.id
  ]

  block_non_us_locations = "enabledForReportingButNotEnforced"

  system_timeout_enabled_ia-11 = "enabledForReportingButNotEnforced"

  mfa_ia-2                          = "enabledForReportingButNotEnforced"
  mfa_ia-2_phishingResistantEnabled = true
  mfa_privileged_ia-2               = "enabledForReportingButNotEnforced"

  block_legacy_authentication = "enabledForReportingButNotEnforced"
  block_risky_signins         = "enabledForReportingButNotEnforced"
  block_risky_users           = "enabledForReportingButNotEnforced"

  block_graph_access = "enabledForReportingButNotEnforced"
  # mg_graph_app_role_assignment_required = false

  block_cloud_admin_portal_access = "enabledForReportingButNotEnforced"
  block_cloud_api_access          = "enabledForReportingButNotEnforced"

  terms_of_use_enabled_ac-08 = "enabledForReportingButNotEnforced"
  terms_of_use_id            = var.terms_of_use_id

  default_group_owners_ids = var.default_group_owners_ids
}

module "log-analytics-breakglass-alerts" {
  providers = {
    azurerm = azurerm.logging
  }
  source = "git@github.com:Sensini7/EntraID-800-53-Terraform-Modules.git//modules/log-analytics-alerts?ref=main"

  alert_users             = var.breakglass_alerts_action_group
  alerts_folder_path      = "${path.module}/alerts"
  resource_group_name     = azurerm_resource_group.rg-monitoring.name
  resource_group_location = azurerm_resource_group.rg-monitoring.location
  action_group_name       = "${var.customer_name}-${var.project_name}-${var.environment_name}-monitoring-action-group"
  law_id                  = azurerm_log_analytics_workspace.law.id
  system_tag              = var.system_tag
  cost_center             = var.log_cost_center
  agency                  = var.log_agency
}

locals {
  law_name = "${var.customer_name}-${var.project_name}-${var.environment_name}-monitoring-law"
}
resource "azurerm_log_analytics_workspace" "law" {
  provider            = azurerm.logging
  name                = local.law_name
  location            = azurerm_resource_group.rg-monitoring.location
  resource_group_name = azurerm_resource_group.rg-monitoring.name
  retention_in_days   = 30

  tags = {
    SYSTEM     = var.system_tag
    CostCenter = var.log_cost_center
    Agency     = var.log_agency
  }
}

locals {
  ## When the `maintenance_mode` variable is set to `true`, the `maintenance_mode_not_scopes` list will be used to allow updates to Azure Policy.
  maintenance_mode_not_scopes = var.maintenance_mode ? [azurerm_resource_group.rg-monitoring.id] : []
}

module "azure-policies-log" {
  providers = {
    azurerm = azurerm.logging
  }
  source                      = "git@github.com:Sensini7/EntraID-800-53-Terraform-Modules.git//modules/azure_policies?ref=main"
  depends_on                  = [module.log-analytics-breakglass-alerts]
  azure_subscription_id       = var.management_logging_subscription_id
  maintenance_mode_not_scopes = local.maintenance_mode_not_scopes

  ## Append/concat resources to this list to prevent them from being destroyed
  prevent_destroy_resource_names = concat(
    [azurerm_log_analytics_workspace.law.name],
    module.log-analytics-breakglass-alerts.prevent_destroy_resource_names,
    var.prevent_destroy_resource_names,
    var.prevent_destroy_event_hub_resource_name,
    local.alert_resource_names
  )
}


module "azure-policies-sec" {
  providers = {
    azurerm = azurerm.security
  }
  ## Only create this if the subscription ID's differ
  count                 = var.management_logging_subscription_id == var.management_security_subscription_id ? 0 : 1
  source                = "git@github.com:Sensini7/EntraID-800-53-Terraform-Modules.git//modules/azure_policies?ref=main"
  depends_on            = [module.log-analytics-breakglass-alerts]
  azure_subscription_id = var.management_security_subscription_id

  ## Append/concat resources to this list to prevent them from being destroyed
  prevent_destroy_resource_names = concat(
    [azurerm_log_analytics_workspace.law.name],
    module.log-analytics-breakglass-alerts.prevent_destroy_resource_names,
    var.prevent_destroy_resource_names,
    var.prevent_destroy_event_hub_resource_name
  )
}

