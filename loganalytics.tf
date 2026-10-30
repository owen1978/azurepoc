resource "azurerm_resource_group" "lawrg" {
  provider = azurerm.operations
  name     = "rg-operations-log-uks-01"
  location = "uksouth"
}

resource "azurerm_log_analytics_workspace" "law" {
  provider = azurerm.operations
  name                = "log-ops-uks-01"
  location            = azurerm_resource_group.lawrg.location
  resource_group_name = azurerm_resource_group.lawrg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  daily_quota_gb      = 2
}