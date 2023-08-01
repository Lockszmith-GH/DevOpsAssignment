resource "azurerm_lb" "lb" {
  location            = var.location
  name                = "${var.shortname}-lb"
  resource_group_name = var.resource_group_name
  sku                 = "Standard"
  frontend_ip_configuration {
    name = "${var.shortname}-fe-ip-conf"
  }
}

resource "azurerm_lb_backend_address_pool" "be_pool" {
  loadbalancer_id = azurerm_lb.lb.id
  name            = "${var.shortname}-be-pool"
}

resource "azurerm_network_security_group" "vm-nsg" {
  location            = var.location
  name                = "${var.location}-nsg"
  resource_group_name = var.resource_group_name
}

resource "azurerm_network_interface_backend_address_pool_association" "be-pool-xref" {
  for_each = { for k, v in var.network_interfaces: k => v }

  network_interface_id    = each.value
  backend_address_pool_id = azurerm_lb_backend_address_pool.be_pool.id
  ip_configuration_name   = "ipconfig1" # each.value.host.
}

resource "azurerm_network_interface_security_group_association" "vm_nsg_assoc" {
  for_each = { for k, v in var.network_interfaces: k => v }

  network_interface_id    = each.value
  network_security_group_id = azurerm_network_security_group.vm-nsg.id
}

resource "azurerm_network_security_rule" "nsrule-allow-ssh" {
  for_each = { for k, v in azurerm_network_interface_security_group_association.vm_nsg_assoc: k => v }

  access                      = "Allow"
  destination_address_prefix  = "*"
  destination_port_range      = "22"
  direction                   = "Inbound"
  name                        = "SSH-${each.key}"
  network_security_group_name = each.key
  priority                    = 300
  protocol                    = "Tcp"
  resource_group_name         = var.resource_group_name
  source_address_prefix       = "*"
  source_port_range           = "*"
}