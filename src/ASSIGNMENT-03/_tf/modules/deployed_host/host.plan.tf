resource "azurerm_linux_virtual_machine" "deployed_host" {
  admin_username        = var.username
  location              = var.location
  name                  = var.host_name
  resource_group_name   = var.resource_group_name
  secure_boot_enabled   = true
  size                  = var.machine_type
  vtpm_enabled          = true
  admin_ssh_key {
    public_key = var.ssh_public_key
    username   = var.username
  }
  boot_diagnostics {
  }
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }
  source_image_reference {
    offer     = "0001-com-ubuntu-server-jammy"
    publisher = "canonical"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }
  network_interface_ids = [ azurerm_network_interface.host_network_interface.id ]
}
