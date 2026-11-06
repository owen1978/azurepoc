# Stop managing the manually run Key Vault without destroying it in Azure.
# These blocks can be deleted after one successful apply.
removed {
  from = azurerm_key_vault.kv

  lifecycle {
    destroy = false
  }
}

removed {
  from = azurerm_resource_group.kvrg

  lifecycle {
    destroy = false
  }
}
