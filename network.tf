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
  name                 = "GatewaySubnet"
  resource_group_name  = azurerm_resource_group.hubvnet.name
  virtual_network_name = azurerm_virtual_network.hubvnet.name
  address_prefixes     = ["10.200.0.0/27"]
}

resource "azurerm_subnet" "azfwsub" {
  name                 = "AzureFirewallSubnet"
  resource_group_name  = azurerm_resource_group.hubvnet.name
  virtual_network_name = azurerm_virtual_network.hubvnet.name
  address_prefixes     = ["10.200.1.0/26"]
}

resource "azurerm_virtual_network_peering" "peeropstohub" {
  name                         = "peering-ops-to-hub"
  resource_group_name          = azurerm_resource_group.opspoke.name
  virtual_network_name         = azurerm_virtual_network.opsvnet.name
  remote_virtual_network_id    = azurerm_virtual_network.hubvnet.id
  allow_virtual_network_access = true
  #use_remote_gateways          = true
}

resource "azurerm_virtual_network_peering" "peerhubtoops" {
  name                         = "peering-hub-to-ops"
  resource_group_name          = azurerm_resource_group.hubvnet.name
  virtual_network_name         = azurerm_virtual_network.hubvnet.name
  remote_virtual_network_id    = azurerm_virtual_network.opsvnet.id
  allow_virtual_network_access = true
  #allow_gateway_transit        = true
  allow_forwarded_traffic = true
}

resource "azurerm_virtual_network_peering" "peerprdtohub" {
  name                         = "peering-prd-to-hub"
  resource_group_name          = azurerm_resource_group.prdspoke.name
  virtual_network_name         = azurerm_virtual_network.prdvnet.name
  remote_virtual_network_id    = azurerm_virtual_network.hubvnet.id
  allow_virtual_network_access = true
  #use_remote_gateways          = true
}

resource "azurerm_virtual_network_peering" "peerhubtoprd" {
  name                         = "peering-hub-to-prd"
  resource_group_name          = azurerm_resource_group.hubvnet.name
  virtual_network_name         = azurerm_virtual_network.hubvnet.name
  remote_virtual_network_id    = azurerm_virtual_network.prdvnet.id
  allow_virtual_network_access = true
  #allow_gateway_transit        = true
  #allow_forwarded_traffic = true
}

resource "azurerm_virtual_network_peering" "peeropstoprd" {
  name                         = "peering-ops-to-prd"
  resource_group_name          = azurerm_resource_group.opspoke.name
  virtual_network_name         = azurerm_virtual_network.opsvnet.name
  remote_virtual_network_id    = azurerm_virtual_network.prdvnet.id
  allow_virtual_network_access = true
}

resource "azurerm_virtual_network_peering" "peerprdtoops" {
  name                         = "peering-prd-to-ops"
  resource_group_name          = azurerm_resource_group.prdspoke.name
  virtual_network_name         = azurerm_virtual_network.prdvnet.name
  remote_virtual_network_id    = azurerm_virtual_network.opsvnet.id
  allow_virtual_network_access = true
}