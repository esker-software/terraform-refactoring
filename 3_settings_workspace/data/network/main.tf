module "settings" {
  source = "../../settings"
}

data "azurerm_subnet" "my_subnet" {
  name                 = module.settings.subnet_name
  virtual_network_name = module.settings.vnet_name
  resource_group_name  = module.settings.resource_group_name
}

output "my_subnet" {
  value = data.azurerm_subnet.my_subnet
}