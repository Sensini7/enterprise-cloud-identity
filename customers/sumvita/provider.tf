provider "azuread" {
  tenant_id = var.management_tenant_tenant_id
  client_id = var.management_tenant_client_id
}

provider "azurerm" {
  features {}
  alias           = "security"
  tenant_id       = var.management_tenant_tenant_id
  subscription_id = var.management_security_subscription_id
}

provider "azurerm" {
  features {}
  alias           = "logging"
  tenant_id       = var.management_tenant_tenant_id
  subscription_id = var.management_logging_subscription_id
}
