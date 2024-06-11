locals {
  # read the virtual wan settings from the settings file if it exists
  virtual_wan_config = try(yamldecode(file("${path.module}/settings.virtual_wan.yml")), {})

  # Generate a map of configs for the hub vnet connections
  dataexp_vwan_vnet_connections = { for k, v in module.dataexp_vnet : "dataexp_${k}" => {
    virtual_network_connection_name = v.name
    name                            = v.name
    virtual_hub_key                 = one([for hk, hv in try(local.virtual_wan_config.virtual_hubs, {}) : hk if hv.location == v.resource.location][*])
    remote_virtual_network_id       = v.resource_id
    internet_security_enabled       = var.azure_firewall_enabled
    }
  }
  vwan_vnet_connections = merge(
    try(local.virtual_wan_config.virtual_network_connections, {}),
    local.dataexp_vwan_vnet_connections,
  )


}

module "virtual_wan" {
  source  = "Azure/avm-ptn-virtualwan/azurerm"
  version = "~> 0.4.0"
  count   = local.connectivity_required && var.virtual_wan_enabled ? 1 : 0

  # Mandatory resource attributes
  allow_branch_to_branch_traffic = try(local.virtual_wan_config.allow_branch_to_branch_traffic, false)
  location                       = try(local.virtual_wan_config.location, var.default_location)
  resource_group_name            = try(local.virtual_wan_config.resource_group_name, "rg-connectivity-${local.enterprise_scale_config.root_id}-01")
  virtual_wan_name               = try(local.virtual_wan_config.virtual_wan_name, "vwan-${local.enterprise_scale_config.root_id}-01")

  # Optional resource attributes
  create_resource_group                 = try(local.virtual_wan_config.create_resource_group, true)
  disable_vpn_encryption                = try(local.virtual_wan_config.disable_vpn_encryption, false)
  enable_telemetry                      = try(local.virtual_wan_config.enable_telemetry, true)
  er_circuit_connections                = try(local.virtual_wan_config.er_circuit_connections, {})
  expressroute_gateways                 = try(local.virtual_wan_config.expressroute_gateways, {})
  firewalls                             = var.azure_firewall_enabled ? module.firewall_azure[0].firewall_config : null
  office365_local_breakout_category     = try(local.virtual_wan_config.office365_local_breakout_category, "None")
  p2s_gateway_vpn_server_configurations = try(local.virtual_wan_config.p2s_gateway_vpn_server_configurations, {})
  p2s_gateways                          = try(local.virtual_wan_config.p2s_gateways, {})
  virtual_hubs                          = try(local.virtual_wan_config.virtual_hubs, {})
  virtual_network_connections           = local.vwan_vnet_connections
  type                                  = try(local.virtual_wan_config.type, "Standard")
  routing_intents                       = var.azure_firewall_enabled ? module.firewall_azure[0].routing_intents : {}
  resource_group_tags                   = try(local.virtual_wan_config.resource_group_tags, {})
  virtual_wan_tags                      = try(local.virtual_wan_config.virtual_wan_tags, {})
  vpn_gateways                          = try(local.virtual_wan_config.vpn_gateways, {})
  vpn_site_connections                  = try(local.virtual_wan_config.vpn_site_connections, {})
  vpn_sites                             = try(local.virtual_wan_config.vpn_sites, {})
  tags                                  = try(local.virtual_wan_config.tags, {})

  providers = {
    azurerm = azurerm.connectivity
  }

  depends_on = [
    module.enterprise_scale,
  ]
}
