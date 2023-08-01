resource "azurerm_virtual_network" "local_network" {
  address_space       = [ var.local_network_cidr ]
  location            = var.location
  name                = "${var.host_name}-vnet"
  resource_group_name = var.resource_group_name
}

resource "azurerm_subnet" "local_subnet" {
  address_prefixes     = [ var.local_subnet_cidr ]
  name                 = "default"
  resource_group_name = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.local_network.name
}

resource "azurerm_public_ip" "host_public_ip" {
  name                = "${var.host_name}-ip"
  allocation_method   = "Static"
  domain_name_label   = var.host_name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "Standard"
}

resource "azurerm_network_interface" "host_network_interface" {
  name                = "${var.host_name}-nic"
  location            = var.location
  resource_group_name = var.resource_group_name
  ip_configuration {
    name                          = "ipconfig1"
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.host_public_ip.id
    subnet_id                     = azurerm_subnet.local_subnet.id
  }
}