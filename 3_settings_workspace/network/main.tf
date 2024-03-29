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

resource "azurerm_virtual_network" "network" {
  name                = "my-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = module.settings.location
  resource_group_name = module.settings.resource_group_name
}

resource "azurerm_subnet" "my_subnet" {
  name                 = "my_subnet"
  virtual_network_name = azurerm_virtual_network.network.name
  resource_group_name  = module.settings.resource_group_name
  address_prefixes       = ["10.0.1.0/28"]
}