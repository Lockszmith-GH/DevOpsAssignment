variable "username" {
    type = string
    description = "VMs admin username"
}

variable "ssh_public_key" {
    type = string
    description = "SSH public signature's of the admin"
}

variable "machine_type" {
    type = string
    description = "Machine type/size"
    default = "Standard_B1s" # Defaulting to the 750 free hours tier machine.
}

variable "host_name" {
    type = string
    description = "Name of VM instance"
}

variable "resource_group_name" {
    type = string
    description = "Azure resource group name"
}

variable "location" {
    type = string
    description = "location of resource"
    default = "eastus"
}

variable "local_network_cidr" {
    type = string
    description = "CIDR Range of the local virtual network"
}

variable "local_subnet_cidr" {
    type = string
    description = "CIDR Range of the local subnet, usually contained within the local_network_cidr"
}