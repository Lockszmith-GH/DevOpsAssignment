output "resources" {
  value = {
    host = azurerm_linux_virtual_machine.deployed_host
    nic = azurerm_network_interface.host_network_interface
    net = azurerm_virtual_network.local_network
    subnet = azurerm_subnet.local_subnet
    pub_ip = azurerm_public_ip.host_public_ip
  }
  sensitive = false
}