resource "azurerm_resource_group" "rg-monitoring" {
  provider = azurerm.logging
  location = var.primary_region
  name     = "${var.customer_name}-${var.project_name}-${var.environment_name}-monitoring-rg"

  tags = {
    SYSTEM     = var.system_tag
    CostCenter = var.sec_cost_center
    Agency     = var.sec_agency
  }
}

resource "azurerm_resource_group" "breakglass-secrets" {
  provider = azurerm.security
  location = var.primary_region
  name     = "${var.customer_name}-${var.project_name}-${var.environment_name}-${var.primary_region}-emergency-accounts-rg"

  tags = {
    SYSTEM     = var.system_tag
    CostCenter = var.sec_cost_center
    Agency     = var.sec_agency
  }
}

resource "azurerm_resource_group" "rg-authmethods" {
  provider = azurerm.security
  location = var.primary_region
  name     = "${var.customer_name}-${var.project_name}-${var.environment_name}-authmethods-rg"

  tags = {
    SYSTEM     = var.system_tag
    CostCenter = var.sec_cost_center
    Agency     = var.sec_agency
  }
}