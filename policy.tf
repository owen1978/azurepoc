resource "azurerm_policy_definition" "require_rg_tags" {
  name                = "azurepoc-require-rg-tags"
  management_group_id = data.azurerm_management_group.azurepoc.id
  policy_type         = "Custom"
  mode                = "All"
  display_name        = "Require tags and values on resource groups"

  metadata = jsonencode({ category = "Tags" })

  parameters = jsonencode({
    costCentre = {
      type         = "String"
      defaultValue = "IT"
      metadata     = { displayName = "CostCentre value" }
    }
    department = {
      type         = "String"
      defaultValue = "IT"
      metadata     = { displayName = "Department value" }
    }
    environmentValues = {
      type         = "Array"
      defaultValue = ["Connectivity", "Operations", "Production"]
      metadata     = { displayName = "Allowed Environment values" }
    }
  })

  policy_rule = jsonencode({
    if = {
      allOf = [
        { field = "type", equals = "Microsoft.Resources/subscriptions/resourceGroups" },
        {
          anyOf = [
            { field = "tags['CostCentre']", notEquals = "[parameters('costCentre')]" },
            { field = "tags['Department']", notEquals = "[parameters('department')]" },
            { field = "tags['Environment']", notIn = "[parameters('environmentValues')]" }
          ]
        }
      ]
    }
    then = { effect = "audit" }
  })
}

resource "azurerm_policy_definition" "subnet_requires_nsg" {
  name                = "azurepoc-subnet-requires-nsg"
  management_group_id = data.azurerm_management_group.azurepoc.id
  policy_type         = "Custom"
  mode                = "All"
  display_name        = "Subnets should have a network security group"

  metadata = jsonencode({ category = "Network" })

  parameters = jsonencode({
    excludedSubnets = {
      type         = "Array"
      defaultValue = ["GatewaySubnet", "AzureFirewallSubnet"]
      metadata     = { displayName = "Subnets excluded from the NSG requirement" }
    }
  })

  policy_rule = jsonencode({
    if = {
      allOf = [
        { field = "type", equals = "Microsoft.Network/virtualNetworks/subnets" },
        { field = "name", notIn = "[parameters('excludedSubnets')]" },
        { field = "Microsoft.Network/virtualNetworks/subnets/networkSecurityGroup.id", exists = "false" }
      ]
    }
    then = { effect = "audit" }
  })
}

resource "azurerm_policy_set_definition" "initiative" {
  name                = "azurepoc_policy"
  management_group_id = data.azurerm_management_group.azurepoc.id
  policy_type         = "Custom"
  display_name        = "azurepoc_policy"

  parameters = jsonencode({
    allowedLocations = {
      type = "Array"
      metadata = {
        description = "The list of allowed locations for resources."
        displayName = "Allowed locations"
        strongType  = "location"
      }
      defaultValue = ["uksouth"]
    }
  })

  # 1a. Allowed locations for resource groups (built-in)
  policy_definition_reference {
    reference_id         = "allowed-locations-rg"
    policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/e765b5de-1225-4ba3-bd56-1ac6695af988"
    parameter_values = jsonencode({
      listOfAllowedLocations = { value = "[parameters('allowedLocations')]" }
    })
  }

  # 1b. Allowed locations for resources (built-in)
  policy_definition_reference {
    reference_id         = "allowed-locations-resources"
    policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/e56962a6-4747-49cd-b67b-bf8b01975c4c"
    parameter_values = jsonencode({
      listOfAllowedLocations = { value = "[parameters('allowedLocations')]" }
    })
  }

  # 2. Required tags on resource groups
  policy_definition_reference {
    reference_id         = "require-rg-tags"
    policy_definition_id = azurerm_policy_definition.require_rg_tags.id
  }

  # 3. Deny public IPs on VM network interfaces (built-in, effect Deny)
  policy_definition_reference {
    reference_id         = "deny-nic-public-ip"
    policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/83a86a26-fd1f-447c-b59d-e51f44264114"
  }

  # 4. NSG required on subnets (audit)
  policy_definition_reference {
    reference_id         = "subnet-requires-nsg"
    policy_definition_id = azurerm_policy_definition.subnet_requires_nsg.id
  }
}

resource "azurerm_management_group_policy_assignment" "azurepoc" {
  name                 = "azurepoc-policy"
  display_name         = "azurepoc_policy"
  management_group_id  = data.azurerm_management_group.azurepoc.id
  policy_definition_id = azurerm_policy_set_definition.initiative.id
}
