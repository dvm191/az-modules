resource "azurerm_network_interface" "nic" {
  name                = "${var.vm_name}_nic"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.ip_configurations[0].subnet_id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_virtual_machine" "windows_vm" {
  name                  = var.vm_name
  location              = var.location
  resource_group_name   = var.resource_group_name
  network_interface_ids = [azurerm_network_interface.nic.id]
  vm_size               = try(var.vm_size, "Standard_DS2_v2")

  storage_os_disk {
    name              = try(var.os_disk_name, "${var.vm_name}_os_disk")
    caching           = try(var.os_disk_caching, "ReadWrite") 
    create_option     = try(var.os_disk_create_option, "FromImage") 
    managed_disk_type = try(var.os_disk_managed_disk_type, "Standard_LRS") 
    disk_size_gb      = try(var.os_disk_size_gb, 128)

  }

  storage_image_reference {
    publisher = try(var.image_publisher, "MicrosoftWindowsServer")
    offer     = try(var.image_offer, "WindowsServer")
    sku       = try(var.image_sku, "2019-Datacenter")
    version   = try(var.image_version, "latest")
  }

  os_profile {
    computer_name  = try(var.vm_name, "windowsvm")
    admin_username = var.admin_username
    admin_password = var.admin_password
  }

  os_profile_windows_config {
    provision_vm_agent        = try(var.provision_vm_agent, true)
    # enable_automatic_updates  = true
  }
}
