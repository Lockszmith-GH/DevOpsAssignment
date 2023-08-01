resource "azurerm_resource_group" "res-group" {
  location = "northeurope"
  name     = "varonis-assignment-03"
}

locals {
  resource_group_name = azurerm_resource_group.res-group.name

  username       = "sz"
  ssh_public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDYnCJkpvIoEzjoYBmGKekFXGEOOlfcxD3RTtoYYy+b8PTVeyhY609UTn713hUxC/WKtY2QZgxs02GMmPfkqDTnt8JiD+PRMANBwYZPEe3BkuLoLFznFAb81ATpNbhqX26yauYLDSfoqUZ2EoRoKZvgKu0woNUrEHcQ1/Be28lF3vHdHga+Xo3xsH7cxIl5yHlbgfgtSPlqPckuiuu+V0I8rsPSW+fiP4NqZWjirm85QQPh0+CriFm5N+EKRhanLN+w5O//Ev0ZgOMR8CX+S62BqqG+DiW11irL7//1Z0oeRuBaeiuw1H5g38Gk6PFX1+GjaBm5bAg/ymej5f+F3HBpMvpSFKcUhe1hoqDP2cy6kSTGjl5HxOmL9uclq9NApyw+einkvL/t69ET1OzN4LMTjQjeWLzmrouG5suarhVlp8Lrup3/L6AaPyN2I81+lFlOTh2PJMlPlxtzcD1lT8IFhb7OFuk1Y7fC/gzDVgmH6E1Gqsw4+eg3k0IsdNZxa5M= szkolnik@Sygin"

  locations = tomap({
    "eastus" = {
      shortname = "use"
      zones     = ["1", "2", "3"]
    }
    "northeurope" = {
      shortname = "eun"
      zones     = ["1", "2", "3"]
    }
  })

  vm_list = tomap({
    "use-vm1" = {
      location     = "eastus"
      network_cidr = "10.1.0.0/16"
      subnet_cidr  = "10.1.0.0/24"
    }
    "use-vm2" = {
      location     = "eastus"
      network_cidr = "10.1.0.0/16"
      subnet_cidr  = "10.1.1.0/24"
    }
    "eun-vm1" = {
      location     = "northeurope"
      network_cidr = "10.2.0.0/16"
      subnet_cidr  = "10.2.0.0/24"
    }
    "eun-vm2" = {
      location     = "northeurope"
      network_cidr = "10.2.0.0/16"
      subnet_cidr  = "10.2.1.0/24"
    }
  })
}

module "deployed_host" {
  source = "./modules/deployed_host"

  for_each = local.vm_list

  host_name = each.key
  location  = each.value.location

  resource_group_name = local.resource_group_name
  username            = local.username
  ssh_public_key      = local.ssh_public_key

  local_network_cidr = each.value.network_cidr
  local_subnet_cidr  = each.value.subnet_cidr
}

# output "debug" {
#   value = [ for o in module.deployed_host : o.resources.host.name ]
# }
