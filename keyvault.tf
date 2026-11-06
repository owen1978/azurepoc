data "azurerm_client_config" "operations" {
  provider = azurerm.operations
}

resource "azurerm_resource_group" "kvrg" {
  provider = azurerm.operations
  name     = "rg-operations-kv-uks-01"
  location = "uksouth"
}

resource "azurerm_key_vault" "kv" {
  provider                   = azurerm.operations
  name                       = "kv-azurepoc-ops-uks01"
  location                   = azurerm_resource_group.kvrg.location
  resource_group_name        = azurerm_resource_group.kvrg.name
  tenant_id                  = data.azurerm_client_config.operations.tenant_id
  sku_name                   = "standard"
  rbac_authorization_enabled = true
  soft_delete_retention_days = 7
  purge_protection_enabled   = true
}

resource "azurerm_role_assignment" "kv_pipeline" {
  provider             = azurerm.operations
  scope                = azurerm_key_vault.kv.id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = data.azurerm_client_config.operations.object_id
}

# One generated password per VM.
resource "random_password" "dc_admin" {
  length           = 24
  min_upper        = 2
  min_lower        = 2
  min_numeric      = 2
  min_special      = 2
  override_special = "!#%*-_=+"
}

resource "random_password" "test_admin" {
  length           = 24
  min_upper        = 2
  min_lower        = 2
  min_numeric      = 2
  min_special      = 2
  override_special = "!#%*-_=+"
}

resource "azurerm_key_vault_secret" "dc_admin" {
  provider     = azurerm.operations
  name         = "dc01-admin-password"
  value        = random_password.dc_admin.result
  key_vault_id = azurerm_key_vault.kv.id
  content_type = "password"

  depends_on = [azurerm_role_assignment.kv_pipeline]
}

resource "azurerm_key_vault_secret" "test_admin" {
  provider     = azurerm.operations
  name         = "testvm-admin-password"
  value        = random_password.test_admin.result
  key_vault_id = azurerm_key_vault.kv.id
  content_type = "password"

  depends_on = [azurerm_role_assignment.kv_pipeline]
}
