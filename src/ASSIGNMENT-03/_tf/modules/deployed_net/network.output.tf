output "all" {
  value = {
    lb           = azurerm_lb.lb
    be_pool      = azurerm_lb_backend_address_pool.be_pool
    nsg          = azurerm_network_security_group.vm-nsg
    xref         = azurerm_network_interface_backend_address_pool_association.be-pool-xref
    vm_nsg_assoc = azurerm_network_interface_security_group_association.vm_nsg_assoc
    ssh          = azurerm_network_security_rule.nsrule-allow-ssh
  }
}
