provider "azurerm" {
  version = "~> 2.0"
  features {}
  skip_provider_registration = true
}

terraform {
  required_version = ">= 0.13"
  backend "azurerm" {
    resource_group_name  = "QA-TERRAFORM"
    storage_account_name = "eskerqaterraform"
    container_name       = "test-rg"
    key                  = "test-rg-new.tfstate"
  }
}

locals {
  location            = "westeurope"
  resource_group_name = "test_rg"
}

resource "azurerm_resource_group" "resourcegroup" {
  name     = local.resource_group_name
  location = local.location
}
