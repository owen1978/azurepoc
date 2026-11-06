resource "azurerm_resource_group" "dcvmrg" {
  provider = azurerm.operations
  name     = "rg-operations-dcvm-uks-01"
  location = "uksouth"
}

resource "azurerm_resource_group" "testvmrg" {
  provider = azurerm.production
  name     = "rg-production-testvm-uks-01"
  location = "uksouth"
}

resource "azurerm_network_interface" "dcnic" {
  provider            = azurerm.operations
  name                = "nic-operations-dc-uks-01"
  location            = azurerm_resource_group.dcvmrg.location
  resource_group_name = azurerm_resource_group.dcvmrg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.identitysub.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.201.0.5"
  }
}

resource "azurerm_windows_virtual_machine" "dcvm" {
  provider            = azurerm.operations
  name                = "vm-dc01-ops-uks-01"
  computer_name       = "dc01"
  resource_group_name = azurerm_resource_group.dcvmrg.name
  location            = azurerm_resource_group.dcvmrg.location
  size                = "Standard_D2als_v6"
  admin_username      = "dcadmin"
  admin_password      = data.azurerm_key_vault_secret.dc_admin.value
  network_interface_ids = [
    azurerm_network_interface.dcnic.id,
  ]

  os_disk {
    name                 = "osdisk-vm-dc01-ops-uks-01"
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
    disk_size_gb         = 127
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-datacenter-gensecond"
    version   = "latest"
  }
}

resource "azurerm_network_interface" "testnic" {
  provider            = azurerm.production
  name                = "nic-production-testvm-uks-01"
  location            = azurerm_resource_group.testvmrg.location
  resource_group_name = azurerm_resource_group.testvmrg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.testsub.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.202.1.5"
  }
}

resource "azurerm_windows_virtual_machine" "testvm" {
  provider            = azurerm.production
  name                = "vm-test-prd-uks-01"
  computer_name       = "test01"
  resource_group_name = azurerm_resource_group.testvmrg.name
  location            = azurerm_resource_group.testvmrg.location
  size                = "Standard_B2s"
  admin_username      = "vmadmin"
  admin_password      = data.azurerm_key_vault_secret.test_admin.value
  network_interface_ids = [
    azurerm_network_interface.testnic.id,
  ]

  os_disk {
    name                 = "osdisk-vm-test-prd-uks-01"
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
    disk_size_gb         = 127
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-datacenter-gensecond"
    version   = "latest"
  }
}

