# Manage firewall deployment
locals {
  firewalls_config = try(yamldecode(file("${path.module}/settings.firewalls.yml")), {})
}

module "firewall_azure" {
  source = "./modules/firewall_azure"
  count  = var.azure_firewall_enabled ? 1 : 0

  # Mandatory resource attributes
  location            = try(local.firewalls_config.location, var.default_location)
  resource_group_name = try(local.firewalls_config.resource_group_name, "rg-firewall-01")
  policy_name         = try(local.firewalls_config.policy_name, "afwp-${local.enterprise_scale_config.root_id}-01")
  regions_by_name     = module.regions.regions_by_name

  # Optional resource attributes
  sku_tier     = try(local.firewalls_config.sku_tier, null)
  firewalls    = try(local.firewalls_config.firewalls, null)
  vwan_enabled = var.virtual_wan_enabled


  providers = {
    azurerm = azurerm.connectivity
  }
}