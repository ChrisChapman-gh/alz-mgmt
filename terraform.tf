terraform {
  required_version = "~> 1.6"
  required_providers {
    azurerm = "~> 3.88"
    azapi = {
      source  = "Azure/azapi"
      version = "~> 1.13"
    }
  }
  backend "azurerm" {}
}

provider "azurerm" {
  skip_provider_registration = true
  storage_use_azuread        = true
  features {}
}

provider "azurerm" {
  alias                      = "management"
  subscription_id            = var.subscription_id_management
  skip_provider_registration = true
  storage_use_azuread        = true
  features {}
}

provider "azurerm" {
  alias                      = "connectivity"
  subscription_id            = var.subscription_id_connectivity != "" ? var.subscription_id_connectivity : null
  skip_provider_registration = true
  features {}
}
