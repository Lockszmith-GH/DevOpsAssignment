variable "resource_group_name" {
    type = string
    description = "Azure resource group name"
}

variable "location" {
    type = string
    description = "Resource location (eastus / northeurope)"
}

variable "shortname" {
    type = string
    description = "Short name of the resource's location (use / eun)"
}

variable "zones" {
    type = list(string)
    description = "Short name of the resource's location (use / eun)"
    default = ["1", "2", "3"]
}

variable "network_interfaces" {
    type = list(string)
    description = "list of network interfaces to associate with the deployed network"
}