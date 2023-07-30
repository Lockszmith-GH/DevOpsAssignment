terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "~>2.0"
    }

    random = {
      source  = "hashicorp/random"
      version = "~>3.0"
    }
  }
}

provider "azurerm" {
  features {}

  subscription_id   = "ced61991-09cf-4e19-a773-fa454609e1ed"
  tenant_id         = "6b4b1b0d-23f1-4063-bbbd-b65e2984b893"
  # Client ID of SzTerraform service-prinicipal:
  # Azure Active Directory -> App registration -> SzTerraform
  client_id         = "0de043f8-9006-4791-baa1-f48a60809c1c"
  client_secret     = local.secret
}
