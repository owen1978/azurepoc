terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=5.2.0"
    }
  }

  backend "azurerm" {
    resource_group_name  = "rg-tfstate"
    storage_account_name = "stazurepoctfstate001"
    container_name       = "tfstate"
    key                  = "azurepoc.tfstate"
    use_azuread_auth     = true
    use_oidc             = true
  }
}

provider "azurerm" {
  features {}
}

provider "azurerm" {
  alias           = "operations"
  subscription_id = local.subscription_ids_by_name["azurepoc-operations"]
  features {}
}

provider "azurerm" {
  alias           = "connectivity"
  subscription_id = local.subscription_ids_by_name["azurepoc-connectivity"]
  features {}
}

provider "azurerm" {
  alias           = "production"
  subscription_id = local.subscription_ids_by_name["azurepoc-production"]
  features {}
}