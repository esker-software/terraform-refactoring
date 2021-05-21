provider "azurerm" {
  version = "~> 2.0"
  features {}
  skip_provider_registration = true
}

terraform {
  required_version = ">= 0.13"
}

locals {
  hostname_web_vm     = "my-web-vm"
}

module settings {
  source = "../settings"
}

module network {
  source = "../data/network"
}

resource "azurerm_availability_set" "web-avset" {
  name                         = "${local.hostname_web_vm}-av"
  location                     = module.settings.location
  resource_group_name          = module.settings.resource_group_name
  platform_fault_domain_count  = 2
  platform_update_domain_count = 20
  managed                      = true
}

resource "azurerm_network_interface" "web-vm-nic" {
  name                = "${local.hostname_web_vm}-nic"
  location            = module.settings.location
  resource_group_name = module.settings.resource_group_name
  ip_configuration {
    name                          = "${local.hostname_web_vm}-ipconfig"
    subnet_id                     = module.network.my_subnet.id
    private_ip_address_allocation = "Dynamic"
  }
  enable_accelerated_networking = true
}

resource "azurerm_linux_virtual_machine" "web-vm" {
  name                  = local.hostname_web_vm
  location              = module.settings.location
  resource_group_name   = module.settings.resource_group_name
  availability_set_id   = azurerm_availability_set.web-avset.id
  size               = "Standard_DS2_v2"
  network_interface_ids = [azurerm_network_interface.web-vm-nic.id]

  admin_username = "myadmin"
  admin_password = "verysecurepassword01?"
  disable_password_authentication = false

  source_image_reference {
    publisher = "OpenLogic"
    offer     = "CentOS"
    sku       = "7.5"
    version   = "latest"
  }

  os_disk {
    name              = "${local.hostname_web_vm}-osdisk"
    caching           = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

}

resource "azurerm_managed_disk" "web-datadisk" {
  name                 = "${local.hostname_web_vm}-datadisk"
  create_option        = "Empty"
  disk_size_gb         = 32
  location             = module.settings.location
  resource_group_name  = module.settings.resource_group_name
  storage_account_type = "Standard_LRS"
}

resource "azurerm_virtual_machine_data_disk_attachment" "web-diskattachment" {
  managed_disk_id    = azurerm_managed_disk.web-datadisk.id
  virtual_machine_id = azurerm_linux_virtual_machine.web-vm.id
  lun                = 0
  caching            = "None"
}