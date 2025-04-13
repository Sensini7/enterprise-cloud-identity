variable "management_tenant_tenant_id" {
  type        = string
  description = "The tenant id of the management tenant"
  sensitive   = true
}

variable "management_security_subscription_id" {
  type        = string
  description = "ID for the management tenants security subscriptions"
}


## Not used but present in common.tfvars

# tflint-ignore: terraform_unused_declarations
variable "key_vault_default_action" {
  description = "Default action for the breakglass user key vault"
  type        = string
}

# tflint-ignore: terraform_unused_declarations
variable "breakglass_display_name" {
  type        = string
  description = "Breakglass users' display name"
  default     = "Breakglass User"
}

# tflint-ignore: terraform_unused_declarations
variable "management_logging_subscription_id" {
  type        = string
  description = "ID for the management tenants logging subscriptions"
}