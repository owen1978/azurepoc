# The Key Vault is deployed manually (outside Terraform).
# Terraform only reads the admin password secrets from it.
# The pipeline identity needs "Key Vault Secrets User" on the vault.
data "azurerm_key_vault" "kv" {
  provider            = azurerm.operations
  name                = "kv-azurepoc-ops-uks01"
  resource_group_name = "rg-operations-kv-uks-01"
}

data "azurerm_key_vault_secret" "dc_admin" {
  provider     = azurerm.operations
  name         = "dcadmin"
  key_vault_id = data.azurerm_key_vault.kv.id
}

data "azurerm_key_vault_secret" "test_admin" {
  provider     = azurerm.operations
  name         = "testadmin"
  key_vault_id = data.azurerm_key_vault.kv.id
}
