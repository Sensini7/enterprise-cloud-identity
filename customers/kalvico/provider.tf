terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.0.0"
    }
  }
  backend "s3" {
  }
  required_version = ">= 1.2.0"
}

provider "azurerm" {
  features {}
  tenant_id       = var.management_tenant_tenant_id
  subscription_id = var.management_security_subscription_id
}
