variable "management_tenant_tenant_id" {
  type        = string
  description = "The tenant id of the management tenant"
  sensitive   = true
}

variable "management_tenant_client_id" {
  type        = string
  description = "The client id of the management tenant"
  sensitive   = true
}

variable "breakglass_user_count" {
  type        = number
  description = "Number of breakglass emergency accounts to be created"
  default     = 2
}

variable "breakglass_display_name" {
  type        = string
  description = "Breakglass users' display name"
  default     = "Breakglass User"
}

variable "default_group_owners_ids" {
  type        = list(string)
  description = "Object IDs of the owners of the Entra ID group of emergency breakglass users."
}

variable "breakglass_alerts_action_group" {
  type = list(object({
    name  = string
    email = string
  }))
  description = "List of name and email of users in the log analytics action group for breakglass sign in alerts."
}

variable "icam_alerts_action_group" {
  type = list(object({
    name  = string
    email = string
  }))
  description = "List of name and email of users in the log analytics action group for breakglass sign in alerts."
}

variable "management_logging_subscription_id" {
  type        = string
  description = "ID for the management tenants logging subscriptions"
}

variable "management_security_subscription_id" {
  type        = string
  description = "ID for the management tenants security subscriptions"
}

variable "prevent_destroy_resource_names" {
  type        = list(string)
  description = "Filter used by azure policies"
  default     = []
}

variable "prevent_destroy_event_hub_resource_name" {
  type        = list(string)
  description = "Concatenated with prevent-destroy-resource-list to prevent deletion of EventHub via azure policy."
  default     = []
}

variable "is_azure_gov" {
  description = "Determines whether the tenant is in Azure Commercial or Azure GovCloud"
  type        = bool
  default     = false
}

variable "primary_region" {
  description = "Azure region used to create resources in (i.e. eastus, usgovvirginia)"
  type        = string
}

variable "customer_name" {
  description = "Customer name, mostly used for resource naming convention"
  type        = string
}

variable "project_name" {
  description = "Project name, mostly used for resource naming convention"
  type        = string
  default     = "icam"
}

variable "environment_name" {
  description = "Name of the environment, mostly used for resource naming convention"
  type        = string
}

variable "system_tag" {
  description = "Used to track cost, these tags are assigned to all components of this solution"
  type        = string
  default     = "ICAM"
}

variable "log_cost_center" {
  description = "Used to apply tags."
  type        = string
  default     = "LogCostCenter"
}

variable "sec_cost_center" {
  description = "Used to apply tags."
  type        = string
  default     = "SecCostCenter"
}

variable "log_agency" {
  description = "Used to apply tags."
  type        = string
  default     = "LogAgency"
}

variable "sec_agency" {
  description = "Used to apply tags."
  type        = string
  default     = "SecAgency"
}

variable "allowed_ip_cidr_list" {
  description = "Access to Azure Resources will allow this IP CIDR range. This should be the enterprise VPN's outgoing IP address range."
  type        = list(string)
  default     = []
}

variable "deployment_enterprise_app_object_id" {
  description = "Objet ID of the service principal used to perform deployments"
  type        = string
}

variable "key_vault_default_action" {
  description = "Default action for the breakglass user key vault"
  type        = string
}

variable "ci_environment_name" {
  description = "Name of the CICD environment"
  type        = string
}