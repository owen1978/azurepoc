resource "azurerm_resource_group" "hubvnet" {
  provider = azurerm.connectivity

  name     = "rg-vnet-connectivity-uks-01"
  location = "uksouth"
}

resource "azurerm_resource_group" "opspoke" {
  provider = azurerm.operations

  name     = "rg-vnet-operations-uks-01"
  location = "uksouth"
}

resource "azurerm_resource_group" "prdspoke" {
  provider = azurerm.production

  name     = "rg-vnet-production-uks-01"
  location = "uksouth"
}

resource "azurerm_resource_group" "hubvpn" {
  provider = azurerm.connectivity

  name     = "rg-vpn-connectivity-uks-01"
  location = "uksouth"
}

resource "azurerm_virtual_network" "opsvnet" {
  provider = azurerm.operations

  name                = "vnet-operations-uks-01"
  location            = azurerm_resource_group.opspoke.location
  resource_group_name = azurerm_resource_group.opspoke.name
  address_space       = ["10.201.0.0/24"]
}

resource "azurerm_virtual_network" "prdvnet" {
  provider = azurerm.production

  name                = "vnet-production-uks-01"
  location            = azurerm_resource_group.prdspoke.location
  resource_group_name = azurerm_resource_group.prdspoke.name
  address_space       = ["10.202.0.0/16"]
}

resource "azurerm_virtual_network" "hubvnet" {
  provider = azurerm.connectivity

  name                = "vnet-connectivity-uks-01"
  location            = azurerm_resource_group.hubvnet.location
  resource_group_name = azurerm_resource_group.hubvnet.name
  address_space       = ["10.200.0.0/16"]
}

resource "azurerm_subnet" "identitysub" {
  provider = azurerm.operations

  name                 = "sub-identity-operations-uks-01"
  resource_group_name  = azurerm_resource_group.opspoke.name
  virtual_network_name = azurerm_virtual_network.opsvnet.name
  address_prefixes     = ["10.201.0.0/28"]
}

resource "azurerm_subnet" "monitorsub" {
  provider = azurerm.operations

  name                 = "sub-monitor-operations-uks-01"
  resource_group_name  = azurerm_resource_group.opspoke.name
  virtual_network_name = azurerm_virtual_network.opsvnet.name
  address_prefixes     = ["10.201.0.16/28"]
}

resource "azurerm_subnet" "testsub" {
  provider = azurerm.production

  name                 = "sub-testing-production-uks-01"
  resource_group_name  = azurerm_resource_group.prdspoke.name
  virtual_network_name = azurerm_virtual_network.prdvnet.name
  address_prefixes     = ["10.202.1.0/26"]
}

resource "azurerm_subnet" "vpnsub" {
  provider = azurerm.connectivity

  name                 = "GatewaySubnet"
  resource_group_name  = azurerm_resource_group.hubvnet.name
  virtual_network_name = azurerm_virtual_network.hubvnet.name
  address_prefixes     = ["10.200.0.0/27"]
}

resource "azurerm_subnet" "azfwsub" {
  provider = azurerm.connectivity

  name                 = "AzureFirewallSubnet"
  resource_group_name  = azurerm_resource_group.hubvnet.name
  virtual_network_name = azurerm_virtual_network.hubvnet.name
  address_prefixes     = ["10.200.1.0/26"]
}

resource "azurerm_virtual_network_peering" "peeropstohub" {
  provider = azurerm.operations

  name                         = "peering-ops-to-hub"
  resource_group_name          = azurerm_resource_group.opspoke.name
  virtual_network_name         = azurerm_virtual_network.opsvnet.name
  remote_virtual_network_id    = azurerm_virtual_network.hubvnet.id
  allow_virtual_network_access = true
  #use_remote_gateways          = true
}

resource "azurerm_virtual_network_peering" "peerhubtoops" {
  provider = azurerm.connectivity

  name                         = "peering-hub-to-ops"
  resource_group_name          = azurerm_resource_group.hubvnet.name
  virtual_network_name         = azurerm_virtual_network.hubvnet.name
  remote_virtual_network_id    = azurerm_virtual_network.opsvnet.id
  allow_virtual_network_access = true
  #allow_gateway_transit        = true
  #allow_forwarded_traffic = true
}

resource "azurerm_virtual_network_peering" "peerprdtohub" {
  provider = azurerm.production

  name                         = "peering-prd-to-hub"
  resource_group_name          = azurerm_resource_group.prdspoke.name
  virtual_network_name         = azurerm_virtual_network.prdvnet.name
  remote_virtual_network_id    = azurerm_virtual_network.hubvnet.id
  allow_virtual_network_access = true
  #use_remote_gateways          = true
}

resource "azurerm_virtual_network_peering" "peerhubtoprd" {
  provider = azurerm.connectivity

  name                         = "peering-hub-to-prd"
  resource_group_name          = azurerm_resource_group.hubvnet.name
  virtual_network_name         = azurerm_virtual_network.hubvnet.name
  remote_virtual_network_id    = azurerm_virtual_network.prdvnet.id
  allow_virtual_network_access = true
  #allow_gateway_transit        = true
  #allow_forwarded_traffic = true
}

resource "azurerm_virtual_network_peering" "peeropstoprd" {
  provider = azurerm.operations

  name                         = "peering-ops-to-prd"
  resource_group_name          = azurerm_resource_group.opspoke.name
  virtual_network_name         = azurerm_virtual_network.opsvnet.name
  remote_virtual_network_id    = azurerm_virtual_network.prdvnet.id
  allow_virtual_network_access = true
}

resource "azurerm_virtual_network_peering" "peerprdtoops" {
  provider = azurerm.production

  name                         = "peering-prd-to-ops"
  resource_group_name          = azurerm_resource_group.prdspoke.name
  virtual_network_name         = azurerm_virtual_network.prdvnet.name
  remote_virtual_network_id    = azurerm_virtual_network.opsvnet.id
  allow_virtual_network_access = true
}