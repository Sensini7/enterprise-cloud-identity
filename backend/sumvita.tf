terraform {
  backend "azurerm" {
    resource_group_name  = "tfstate"
    storage_account_name = "sensiniadtfstate713"
    container_name      = "tfstate"
    key                 = "test-conditional-access-policies.tfstate"
  }
}
