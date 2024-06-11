resource "azurerm_resource_group" "this" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_firewall_policy" "this" {
  name                = var.policy_name
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
}