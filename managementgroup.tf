# The AzurePoc management group, created manually earlier.
# Use the management group ID (the Name/ID column in the Portal), not the display name.
data "azurerm_management_group" "azurepoc" {
  name = "azurepoc"
}

# Every subscription whose name starts with "azurepoc-"
data "azurerm_subscriptions" "poc" {
  display_name_prefix = "azurepoc-"
}

locals {
  # Subscription display name -> management group it should sit in.
  # Adding a subscription means adding one line here.
  subscription_placement = {
    "azurepoc-operations"   = "mg-operations"
    "azurepoc-connectivity" = "mg-connectivity"
    "azurepoc-production"   = "mg-production"
  }

  # Lookup table: display name -> subscription GUID
  subscription_ids_by_name = {
    for s in data.azurerm_subscriptions.poc.subscriptions : s.display_name => s.subscription_id
  }
}

# One management group per distinct target in the map
resource "azurerm_management_group" "child" {
  for_each = toset(values(local.subscription_placement))

  name                       = each.value
  display_name               = each.value
  parent_management_group_id = data.azurerm_management_group.azurepoc.id
}

# Move each subscription into its management group
resource "azurerm_management_group_subscription_association" "placement" {
  for_each = local.subscription_placement

  management_group_id = azurerm_management_group.child[each.value].id
  subscription_id     = "/subscriptions/${local.subscription_ids_by_name[each.key]}"
}