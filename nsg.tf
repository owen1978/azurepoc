resource "azurerm_network_security_group" "sandbox" {
  provider = azurerm.production

  name                = "nsg-production-sandbox-uks-01"
  location            = azurerm_resource_group.prdspoke.location
  resource_group_name = azurerm_resource_group.prdspoke.name

  security_rule {
    name                       = "inbound_jumpbox_tcp"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "192.168.55.20/32"
    destination_address_prefix = "10.202.1.0/26"
  }

  security_rule {
    name                       = "inbound_jumpbox_udp"
    priority                   = 1100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Udp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "192.168.55.20/32"
    destination_address_prefix = "10.202.1.0/26"
  }

  security_rule {
    name                       = "inbound_endpointmgmt"
    priority                   = 2000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_ranges    = ["135", "139", "445"]
    source_address_prefix      = "192.168.50.44/32"
    destination_address_prefix = "10.202.1.0/26"
  }

  security_rule {
    name                       = "inbound_operationsmon"
    priority                   = 2100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_ranges    = ["135", "5985", "5986", "49152-65535"]
    source_address_prefix      = "192.168.50.45/32"
    destination_address_prefix = "10.202.1.0/26"
  }

  security_rule {
    name                       = "deny_all_inbound"
    priority                   = 4096
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "outbound_domain_services_tcp"
    priority                   = 1000
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_ranges    = ["53", "88", "135", "389", "445", "464", "636", "3268", "3269"]
    source_address_prefix      = "*"
    destination_address_prefix = "10.201.0.0/28"
  }

  security_rule {
    name                       = "outbound_domain_services_udp"
    priority                   = 1100
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Udp"
    source_port_range          = "*"
    destination_port_ranges    = ["53", "88", "123", "389"]
    source_address_prefix      = "*"
    destination_address_prefix = "10.201.0.0/28"
  }

  security_rule {
    name                       = "outbound_dynamic_ports_tcp"
    priority                   = 1200
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_ranges    = ["49152-65535"]
    source_address_prefix      = "*"
    destination_address_prefix = "10.201.0.0/28"
  }

  security_rule {
    name                       = "outbound_endpointmgmt"
    priority                   = 2000
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_ranges    = ["8020", "8383", "8027", "8443", "8047", "8031"]
    source_address_prefix      = "*"
    destination_address_prefix = "192.168.50.44/32"
  }

  security_rule {
    name                       = "deny_all_outbound"
    priority                   = 4096
    direction                  = "Outbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "sandboxsubnet" {
  provider = azurerm.production

  subnet_id                 = azurerm_subnet.testsub.id
  network_security_group_id = azurerm_network_security_group.sandbox.id
}

resource "azurerm_network_security_group" "identity" {
  provider = azurerm.operations

  name                = "nsg-operations-domain-uks-01"
  location            = azurerm_resource_group.opspoke.location
  resource_group_name = azurerm_resource_group.opspoke.name

  security_rule {
    name                       = "inbound_jumpbox_tcp"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "192.168.55.20/32"
    destination_address_prefix = "10.201.0.0/28"
  }

  security_rule {
    name                       = "inbound_jumpbox_udp"
    priority                   = 1100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Udp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "192.168.55.20/32"
    destination_address_prefix = "10.201.0.0/28"
  }

  security_rule {
    name                       = "inbound_endpointmgmt"
    priority                   = 1200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_ranges    = ["135", "139", "445"]
    source_address_prefix      = "192.168.50.44/32"
    destination_address_prefix = "10.201.0.0/28"
  }

  security_rule {
    name                       = "inbound_operationsmon"
    priority                   = 1300
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_ranges    = ["135", "5985", "5986", "49152-65535"]
    source_address_prefix      = "192.168.50.45/32"
    destination_address_prefix = "10.201.0.0/28"
  }

  security_rule {
    name                       = "inbound_domain_services_tcp"
    priority                   = 1400
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_ranges    = ["53", "88", "135", "389", "445", "464", "636", "3268", "3269"]
    source_address_prefixes    = ["10.202.1.0/26", "192.168.50.5/32"]
    destination_address_prefix = "10.201.0.0/28"
  }

  security_rule {
    name                       = "inbound_domain_services_udp"
    priority                   = 1500
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Udp"
    source_port_range          = "*"
    destination_port_ranges    = ["53", "88", "123", "389", "464"]
    source_address_prefixes    = ["10.202.1.0/26", "192.168.50.5/32"]
    destination_address_prefix = "10.201.0.0/28"
  }

  security_rule {
    name                       = "inbound_dynamic_ports_tcp"
    priority                   = 1600
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_ranges    = ["49152-65535"]
    source_address_prefixes    = ["10.202.1.0/26", "192.168.50.5/32"]
    destination_address_prefix = "10.201.0.0/28"
  }

  security_rule {
    name                       = "deny_all_inbound"
    priority                   = 4096
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "outbound_endpointmgmt"
    priority                   = 1000
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_ranges    = ["8020", "8383", "8027", "8443", "8047", "8031"]
    source_address_prefix      = "*"
    destination_address_prefix = "192.168.50.44/32"
  }

  security_rule {
    name                       = "outbound_onprem_dc_tcp"
    priority                   = 1200
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_ranges    = ["53", "88", "135", "389", "445", "464", "636", "3268", "3269", "49152-65535"]
    source_address_prefix      = "10.201.0.0/28"
    destination_address_prefix = "192.168.50.5/32"
  }

  security_rule {
    name                       = "outbound_onprem_dc_udp"
    priority                   = 1300
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Udp"
    source_port_range          = "*"
    destination_port_ranges    = ["53", "88", "123", "389", "464"]
    source_address_prefix      = "10.201.0.0/28"
    destination_address_prefix = "192.168.50.5/32"
  }

  security_rule {
    name                       = "deny_all_outbound"
    priority                   = 4096
    direction                  = "Outbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "identitysubnet" {
  provider = azurerm.operations

  subnet_id                 = azurerm_subnet.identitysub.id
  network_security_group_id = azurerm_network_security_group.identity.id
}