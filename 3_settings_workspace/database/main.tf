provider "azurerm" {
  version = "~> 2.0"
  features {}
  skip_provider_registration = true
}

terraform {
  required_version = ">= 0.13"
}

locals {
  hostname_db_vm      = "my-db-vm"
}

module settings {
  source = "../settings"
}

module network {
  source = "../data/network"
}

resource "azurerm_availability_set" "db-avset" {
  name                         = "${local.hostname_db_vm}-av"
  location                     = module.settings.location
  resource_group_name          = module.settings.resource_group_name
  platform_fault_domain_count  = 2
  platform_update_domain_count = 20
  managed                      = true
}

resource "azurerm_network_interface" "db-nic" {
  name                = "${local.hostname_db_vm}-nic"
  location            = module.settings.location
  resource_group_name = module.settings.resource_group_name
  ip_configuration {
    name                          = "${local.hostname_db_vm}-ipconfig"
    subnet_id                     = module.network.my_subnet.id
    private_ip_address_allocation = "Dynamic"
  }
  enable_accelerated_networking = true
}

resource "azurerm_linux_virtual_machine" "db-vm" {
  name                  = local.hostname_db_vm
  location              = module.settings.location
  resource_group_name   = module.settings.resource_group_name
  availability_set_id   = azurerm_availability_set.db-avset.id
  size               = "Standard_DS2_v2"
  network_interface_ids = [azurerm_network_interface.db-nic.id]

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
    name              = "${local.hostname_db_vm}-osdisk"
    caching           = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
}

resource "azurerm_managed_disk" "db-datadisk" {
  name                 = "${local.hostname_db_vm}-datadisk"
  create_option        = "Empty"
  disk_size_gb         = 32
  location             = module.settings.location
  resource_group_name  = module.settings.resource_group_name
  storage_account_type = "Standard_LRS"
}

resource "azurerm_virtual_machine_data_disk_attachment" "db-diskattachment" {
  managed_disk_id    = azurerm_managed_disk.db-datadisk.id
  virtual_machine_id = azurerm_linux_virtual_machine.db-vm.id
  lun                = 0
  caching            = "None"
}
