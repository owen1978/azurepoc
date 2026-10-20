resource "azurerm_resource_group" "hubvnet" {
  name     = "rg-vnet-connectivity-uks-01"
  location = "uksouth"
}

resource "azurerm_resource_group" "opspoke" {
  name     = "rg-vnet-operations-uks-01"
  location = "uksouth"
}

resource "azurerm_resource_group" "prdspoke" {
  name     = "rg-vnet-production-uks-01"
  location = "uksouth"
}

resource "azurerm_resource_group" "hubvpn" {
  name     = "rg-vpn-connectivity-uks-01"
  location = "uksouth"
}

resource "azurerm_virtual_network" "opsvnet" {
  name                = "vnet-operations-uks-01"
  location            = azurerm_resource_group.opspoke.location
  resource_group_name = azurerm_resource_group.opspoke.name
  address_space       = ["10.201.0.0/24"]
}

resource "azurerm_virtual_network" "prdvnet" {
  name                = "vnet-production-uks-01"
  location            = azurerm_resource_group.prdspoke.location
  resource_group_name = azurerm_resource_group.prdspoke.name
  address_space       = ["10.202.0.0/16"]
}

resource "azurerm_virtual_network" "hubvnet" {
  name                = "vnet-connectivity-uks-01"
  location            = azurerm_resource_group.hubvnet.location
  resource_group_name = azurerm_resource_group.hubvnet.name
  address_space       = ["10.200.0.0/16"]
}

resource "azurerm_subnet" "identitysub" {
  name                 = "sub-identity-operations-uks-01"
  resource_group_name  = azurerm_resource_group.opspoke.name
  virtual_network_name = azurerm_virtual_network.opsvnet.name
  address_prefixes     = ["10.201.0.0/28"]
}

resource "azurerm_subnet" "monitorsub" {
  name                 = "sub-monitor-operations-uks-01"
  resource_group_name  = azurerm_resource_group.opspoke.name
  virtual_network_name = azurerm_virtual_network.opsvnet.name
  address_prefixes     = ["10.201.0.16/28"]
}

resource "azurerm_subnet" "testsub" {
  name                 = "sub-testing-production-uks-01"
  resource_group_name  = azurerm_resource_group.prdspoke.name
  virtual_network_name = azurerm_virtual_network.prdvnet.name
  address_prefixes     = ["10.202.1.0/26"]
}

resource "azurerm_subnet" "vpnsub" {
  name                 = "sub-vpn-connectivity-uks-01"
  resource_group_name  = azurerm_resource_group.hubvpn.name
  virtual_network_name = azurerm_virtual_network.hubvnet.name
  address_prefixes     = ["10.200.0.0/27"]
}

resource "azurerm_subnet" "azfwsub" {
  name                 = "sub-azfw-connectivity-uks-01"
  resource_group_name  = azurerm_resource_group.hubvnet.name
  virtual_network_name = azurerm_virtual_network.hubvnet.name
  address_prefixes     = ["10.200.1.0/26"]
}
