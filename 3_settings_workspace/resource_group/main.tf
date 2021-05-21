provider "azurerm" {
  version = "~> 2.0"
  features {}
  skip_provider_registration = true
}

terraform {
  required_version = ">= 0.13"
}

module settings {
  source = "../settings"
}

resource "azurerm_resource_group" "resourcegroup" {
  name     = module.settings.resource_group_name
  location = module.settings.location
}
