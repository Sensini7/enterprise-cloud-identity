resource "azurerm_key_vault" "kv-authmethods" {
  ## checkov:skip=CKV_AZURE_189:Public network access required, limit access via RBAC + VPN IP list.
  ## checkov:skip=CKV2_AZURE_32:No private network to integrate with at this time.
  provider                  = azurerm.security
  name                      = "${var.customer_name}-${var.environment_name}-authmethods"
  location                  = var.primary_region
  sku_name                  = "standard"
  tenant_id                 = var.management_tenant_tenant_id
  resource_group_name       = azurerm_resource_group.rg-authmethods.name
  purge_protection_enabled  = true
  enable_rbac_authorization = true

  network_acls {
    bypass         = "AzureServices"
    default_action = var.key_vault_default_action

    ip_rules = var.allowed_ip_cidr_list
  }

  tags = {
    SYSTEM     = var.system_tag
    CostCenter = var.sec_cost_center
    Agency     = var.sec_agency
  }
}