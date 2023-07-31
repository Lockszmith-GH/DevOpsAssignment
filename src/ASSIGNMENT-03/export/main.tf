resource "azurerm_linux_virtual_machine" "res-0" {
  admin_username        = "sz"
  location              = "eastus"
  name                  = "TMPL-USE-VM1"
  network_interface_ids = ["/subscriptions/ced61991-09cf-4e19-a773-fa454609e1ed/resourceGroups/varonis-assignment-03/providers/Microsoft.Network/networkInterfaces/tmpl-use-vm1329"]
  resource_group_name   = "VARONIS-ASSIGNMENT-03"
  secure_boot_enabled   = true
  size                  = "Standard_B1s"
  vtpm_enabled          = true
  admin_ssh_key {
    public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDYnCJkpvIoEzjoYBmGKekFXGEOOlfcxD3RTtoYYy+b8PTVeyhY609UTn713hUxC/WKtY2QZgxs02GMmPfkqDTnt8JiD+PRMANBwYZPEe3BkuLoLFznFAb81ATpNbhqX26yauYLDSfoqUZ2EoRoKZvgKu0woNUrEHcQ1/Be28lF3vHdHga+Xo3xsH7cxIl5yHlbgfgtSPlqPckuiuu+V0I8rsPSW+fiP4NqZWjirm85QQPh0+CriFm5N+EKRhanLN+w5O//Ev0ZgOMR8CX+S62BqqG+DiW11irL7//1Z0oeRuBaeiuw1H5g38Gk6PFX1+GjaBm5bAg/ymej5f+F3HBpMvpSFKcUhe1hoqDP2cy6kSTGjl5HxOmL9uclq9NApyw+einkvL/t69ET1OzN4LMTjQjeWLzmrouG5suarhVlp8Lrup3/L6AaPyN2I81+lFlOTh2PJMlPlxtzcD1lT8IFhb7OFuk1Y7fC/gzDVgmH6E1Gqsw4+eg3k0IsdNZxa5M= szkolnik@Sygin"
    username   = "sz"
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
  depends_on = [
    azurerm_network_interface.res-10,
  ]
}
resource "azurerm_resource_group" "res-1" {
  location = "northeurope"
  name     = "varonis-assignment-03"
}
resource "azurerm_linux_virtual_machine" "res-2" {
  admin_username        = "sz"
  location              = "northeurope"
  name                  = "tmpl-eun-vm01"
  network_interface_ids = ["/subscriptions/ced61991-09cf-4e19-a773-fa454609e1ed/resourceGroups/varonis-assignment-03/providers/Microsoft.Network/networkInterfaces/tmpl-eun-vm01457"]
  resource_group_name   = "varonis-assignment-03"
  secure_boot_enabled   = true
  size                  = "Standard_B1s"
  vtpm_enabled          = true
  admin_ssh_key {
    public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDYnCJkpvIoEzjoYBmGKekFXGEOOlfcxD3RTtoYYy+b8PTVeyhY609UTn713hUxC/WKtY2QZgxs02GMmPfkqDTnt8JiD+PRMANBwYZPEe3BkuLoLFznFAb81ATpNbhqX26yauYLDSfoqUZ2EoRoKZvgKu0woNUrEHcQ1/Be28lF3vHdHga+Xo3xsH7cxIl5yHlbgfgtSPlqPckuiuu+V0I8rsPSW+fiP4NqZWjirm85QQPh0+CriFm5N+EKRhanLN+w5O//Ev0ZgOMR8CX+S62BqqG+DiW11irL7//1Z0oeRuBaeiuw1H5g38Gk6PFX1+GjaBm5bAg/ymej5f+F3HBpMvpSFKcUhe1hoqDP2cy6kSTGjl5HxOmL9uclq9NApyw+einkvL/t69ET1OzN4LMTjQjeWLzmrouG5suarhVlp8Lrup3/L6AaPyN2I81+lFlOTh2PJMlPlxtzcD1lT8IFhb7OFuk1Y7fC/gzDVgmH6E1Gqsw4+eg3k0IsdNZxa5M= szkolnik@Sygin"
    username   = "sz"
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
  depends_on = [
    azurerm_network_interface.res-7,
  ]
}
resource "azurerm_lb" "res-3" {
  location            = "northeurope"
  name                = "tmpl-eun-lb"
  resource_group_name = "varonis-assignment-03"
  sku                 = "Standard"
  frontend_ip_configuration {
    name = "tmpl-eun-fe-ip-conf"
  }
  depends_on = [
    azurerm_resource_group.res-1,
  ]
}
resource "azurerm_lb_backend_address_pool" "res-4" {
  loadbalancer_id = "/subscriptions/ced61991-09cf-4e19-a773-fa454609e1ed/resourceGroups/varonis-assignment-03/providers/Microsoft.Network/loadBalancers/tmpl-eun-lb"
  name            = "tmpl-eun-be-pool"
  depends_on = [
    azurerm_lb.res-3,
  ]
}
resource "azurerm_lb" "res-5" {
  location            = "eastus"
  name                = "tmpl-use-lb"
  resource_group_name = "varonis-assignment-03"
  sku                 = "Standard"
  frontend_ip_configuration {
    name = "tmpl-use-fe-ip-conf"
  }
  depends_on = [
    azurerm_resource_group.res-1,
  ]
}
resource "azurerm_lb_backend_address_pool" "res-6" {
  loadbalancer_id = "/subscriptions/ced61991-09cf-4e19-a773-fa454609e1ed/resourceGroups/varonis-assignment-03/providers/Microsoft.Network/loadBalancers/tmpl-use-lb"
  name            = "tmpl-use-be-pool"
  depends_on = [
    azurerm_lb.res-5,
  ]
}
resource "azurerm_network_interface" "res-7" {
  location            = "northeurope"
  name                = "tmpl-eun-vm01457"
  resource_group_name = "varonis-assignment-03"
  ip_configuration {
    name                          = "ipconfig1"
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = "/subscriptions/ced61991-09cf-4e19-a773-fa454609e1ed/resourceGroups/varonis-assignment-03/providers/Microsoft.Network/publicIPAddresses/tmpl-eun-vm01-ip"
    subnet_id                     = "/subscriptions/ced61991-09cf-4e19-a773-fa454609e1ed/resourceGroups/varonis-assignment-03/providers/Microsoft.Network/virtualNetworks/tmpl-eun-vm01-vnet/subnets/default"
  }
  depends_on = [
    azurerm_public_ip.res-18,
    azurerm_subnet.res-23,
  ]
}
resource "azurerm_network_interface_backend_address_pool_association" "res-8" {
  backend_address_pool_id = "/subscriptions/ced61991-09cf-4e19-a773-fa454609e1ed/resourceGroups/varonis-assignment-03/providers/Microsoft.Network/loadBalancers/tmpl-eun-lb/backendAddressPools/tmpl-eun-be-pool"
  ip_configuration_name   = "ipconfig1"
  network_interface_id    = "/subscriptions/ced61991-09cf-4e19-a773-fa454609e1ed/resourceGroups/varonis-assignment-03/providers/Microsoft.Network/networkInterfaces/tmpl-eun-vm01457"
  depends_on = [
    azurerm_lb_backend_address_pool.res-4,
    azurerm_network_interface.res-7,
  ]
}
resource "azurerm_network_interface_security_group_association" "res-9" {
  network_interface_id      = "/subscriptions/ced61991-09cf-4e19-a773-fa454609e1ed/resourceGroups/varonis-assignment-03/providers/Microsoft.Network/networkInterfaces/tmpl-eun-vm01457"
  network_security_group_id = "/subscriptions/ced61991-09cf-4e19-a773-fa454609e1ed/resourceGroups/varonis-assignment-03/providers/Microsoft.Network/networkSecurityGroups/tmpl-eun-vm01-nsg"
  depends_on = [
    azurerm_network_interface.res-7,
    azurerm_network_security_group.res-13,
  ]
}
resource "azurerm_network_interface" "res-10" {
  location            = "eastus"
  name                = "tmpl-use-vm1329"
  resource_group_name = "varonis-assignment-03"
  ip_configuration {
    name                          = "ipconfig1"
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = "/subscriptions/ced61991-09cf-4e19-a773-fa454609e1ed/resourceGroups/varonis-assignment-03/providers/Microsoft.Network/publicIPAddresses/tmpl-use-vm1-ip"
    subnet_id                     = "/subscriptions/ced61991-09cf-4e19-a773-fa454609e1ed/resourceGroups/varonis-assignment-03/providers/Microsoft.Network/virtualNetworks/tmpl-use-vm1-vnet/subnets/default"
  }
  depends_on = [
    azurerm_public_ip.res-20,
    azurerm_subnet.res-25,
  ]
}
resource "azurerm_network_interface_backend_address_pool_association" "res-11" {
  backend_address_pool_id = "/subscriptions/ced61991-09cf-4e19-a773-fa454609e1ed/resourceGroups/varonis-assignment-03/providers/Microsoft.Network/loadBalancers/tmpl-use-lb/backendAddressPools/tmpl-use-be-pool"
  ip_configuration_name   = "ipconfig1"
  network_interface_id    = "/subscriptions/ced61991-09cf-4e19-a773-fa454609e1ed/resourceGroups/varonis-assignment-03/providers/Microsoft.Network/networkInterfaces/tmpl-use-vm1329"
  depends_on = [
    azurerm_lb_backend_address_pool.res-6,
    azurerm_network_interface.res-10,
  ]
}
resource "azurerm_network_interface_security_group_association" "res-12" {
  network_interface_id      = "/subscriptions/ced61991-09cf-4e19-a773-fa454609e1ed/resourceGroups/varonis-assignment-03/providers/Microsoft.Network/networkInterfaces/tmpl-use-vm1329"
  network_security_group_id = "/subscriptions/ced61991-09cf-4e19-a773-fa454609e1ed/resourceGroups/varonis-assignment-03/providers/Microsoft.Network/networkSecurityGroups/tmpl-use-vm1-nsg"
  depends_on = [
    azurerm_network_interface.res-10,
    azurerm_network_security_group.res-15,
  ]
}
resource "azurerm_network_security_group" "res-13" {
  location            = "northeurope"
  name                = "tmpl-eun-vm01-nsg"
  resource_group_name = "varonis-assignment-03"
  depends_on = [
    azurerm_resource_group.res-1,
  ]
}
resource "azurerm_network_security_rule" "res-14" {
  access                      = "Allow"
  destination_address_prefix  = "*"
  destination_port_range      = "22"
  direction                   = "Inbound"
  name                        = "SSH"
  network_security_group_name = "tmpl-eun-vm01-nsg"
  priority                    = 300
  protocol                    = "Tcp"
  resource_group_name         = "varonis-assignment-03"
  source_address_prefix       = "*"
  source_port_range           = "*"
  depends_on = [
    azurerm_network_security_group.res-13,
  ]
}
resource "azurerm_network_security_group" "res-15" {
  location            = "eastus"
  name                = "tmpl-use-vm1-nsg"
  resource_group_name = "varonis-assignment-03"
  depends_on = [
    azurerm_resource_group.res-1,
  ]
}
resource "azurerm_network_security_rule" "res-16" {
  access                      = "Allow"
  destination_address_prefix  = "*"
  destination_port_range      = "22"
  direction                   = "Inbound"
  name                        = "SSH"
  network_security_group_name = "tmpl-use-vm1-nsg"
  priority                    = 300
  protocol                    = "Tcp"
  resource_group_name         = "varonis-assignment-03"
  source_address_prefix       = "*"
  source_port_range           = "*"
  depends_on = [
    azurerm_network_security_group.res-15,
  ]
}
resource "azurerm_public_ip" "res-17" {
  allocation_method   = "Static"
  domain_name_label   = "tmpl-eun-lb-addr"
  location            = "northeurope"
  name                = "tmpl-eun-public-ip"
  resource_group_name = "varonis-assignment-03"
  sku                 = "Standard"
  zones               = ["1", "2", "3"]
  depends_on = [
    azurerm_resource_group.res-1,
  ]
}
resource "azurerm_public_ip" "res-18" {
  allocation_method   = "Static"
  domain_name_label   = "tmpl-eun-vm1"
  location            = "northeurope"
  name                = "tmpl-eun-vm01-ip"
  resource_group_name = "varonis-assignment-03"
  sku                 = "Standard"
  depends_on = [
    azurerm_resource_group.res-1,
  ]
}
resource "azurerm_public_ip" "res-19" {
  allocation_method   = "Static"
  domain_name_label   = "tmpl-use-lb-addr"
  location            = "eastus"
  name                = "tmpl-use-public-ip"
  resource_group_name = "varonis-assignment-03"
  sku                 = "Standard"
  zones               = ["1", "2", "3"]
  depends_on = [
    azurerm_resource_group.res-1,
  ]
}
resource "azurerm_public_ip" "res-20" {
  allocation_method   = "Static"
  domain_name_label   = "tmpl-use-vm1"
  location            = "eastus"
  name                = "tmpl-use-vm1-ip"
  resource_group_name = "varonis-assignment-03"
  sku                 = "Standard"
  depends_on = [
    azurerm_resource_group.res-1,
  ]
}
resource "azurerm_traffic_manager_profile" "res-21" {
  name                   = "tmpl-traffic-mgr"
  resource_group_name    = "varonis-assignment-03"
  traffic_routing_method = "Geographic"
  dns_config {
    relative_name = "tmpl-traffic-mgr"
    ttl           = 60
  }
  monitor_config {
    path     = "/"
    port     = 443
    protocol = "HTTP"
  }
  depends_on = [
    azurerm_resource_group.res-1,
  ]
}
resource "azurerm_virtual_network" "res-22" {
  address_space       = ["10.0.0.0/16"]
  location            = "northeurope"
  name                = "tmpl-eun-vm01-vnet"
  resource_group_name = "varonis-assignment-03"
  depends_on = [
    azurerm_resource_group.res-1,
  ]
}
resource "azurerm_subnet" "res-23" {
  address_prefixes     = ["10.0.0.0/24"]
  name                 = "default"
  resource_group_name  = "varonis-assignment-03"
  virtual_network_name = "tmpl-eun-vm01-vnet"
  depends_on = [
    azurerm_virtual_network.res-22,
  ]
}
resource "azurerm_virtual_network" "res-24" {
  address_space       = ["10.1.0.0/16"]
  location            = "eastus"
  name                = "tmpl-use-vm1-vnet"
  resource_group_name = "varonis-assignment-03"
  depends_on = [
    azurerm_resource_group.res-1,
  ]
}
resource "azurerm_subnet" "res-25" {
  address_prefixes     = ["10.1.0.0/24"]
  name                 = "default"
  resource_group_name  = "varonis-assignment-03"
  virtual_network_name = "tmpl-use-vm1-vnet"
  depends_on = [
    azurerm_virtual_network.res-24,
  ]
}
