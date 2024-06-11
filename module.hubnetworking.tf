locals {
  # Read the hubnetworking settings from the settings file if it exists
  hubnetworking_config = try(yamldecode(file("${path.module}/settings.hubnetworking.yml")), {})

  # Generate a map of the required subnets
  subnets = {
    for k, v in local.hubnetworking_config.vnet_hubs : k => {
      AzureFirewallSubnet = var.azure_firewall_enabled ? {
        address_prefixes = cidrsubnets(v.address_prefix, 26 - split("/", v.address_prefix)[1])
      } : null
    }
  }

  # Generate a map of configs for the hub vnet connections
  # dataexp_hub_vnet_connections = {
  #   for k, v in local.dataexp_instances : "dataexp_${k}" => {
  #     dataexp_virtual_network_id   = module.dataexp_vnet[k].resource_id
  #     dataexp_virtual_network_name = module.dataexp_vnet[k].name
  #     dataexp_resource_group_name  = azapi_resource.dataexp_rg[k].name
  #     hub_virtual_network_id       = module.hubnetworking[0].virtual_networks[v.config.network_hub].id
  #     hub_virtual_network_name     = module.hubnetworking[0].virtual_networks[v.config.network_hub].name
  #     hub_resource_group_name      = module.hubnetworking[0].virtual_networks[v.config.network_hub].resource_group_name
  #   }
  # }
}

module "hubnetworking" {
  source  = "Azure/hubnetworking/azurerm"
  version = "~> 1.1"
  count   = var.virtual_wan_enabled ? 0 : 1

  hub_virtual_networks = {
    for k, v in local.hubnetworking_config.vnet_hubs : k => {
      # Mandatory resource attributes
      address_space       = [v.address_prefix]
      location            = v.location
      name                = coalesce(try(v.name, ""), "vnet-${local.enterprise_scale_config.root_id}-${v.location}-01")
      resource_group_name = coalesce(try(v.resource_group_name, ""), "rg-${local.enterprise_scale_config.root_id}-hub-${v.location}-01")

      # Optional resource attributes
      firewall = var.azure_firewall_enabled ? merge(
        module.firewall_azure[0].firewall_config[k],
        {
          subnet_address_prefix = local.subnets[k].AzureFirewallSubnet.address_prefixes[0]
          default_ip_configuration = {
            name = "default"
            public_ip_config = {
              name       = "pip-afw-${k}"
              zones      = module.firewall_azure[0].firewall_config[k].zones
              ip_version = "IPv4"
              sku_tier   = "Regional"
            }
          }
        }
      ) : null
      resource_group_lock_enabled = false
      subnets                     = { for subnet_k, subnet_v in local.subnets[k] : subnet_k => subnet_v if !contains(["AzureFirewallSubnet"], subnet_k) }
    }
  }

  providers = {
    azurerm = azurerm.connectivity
  }

  depends_on = [
    module.enterprise_scale,
  ]
}



# # Peer managed networks
# # Using api to bypass subscription provider
# resource "azapi_resource" "dataexp_to_hubnetworking" {
#   for_each = local.dataexp_hub_vnet_connections

#   # Mandatory resource attributes
#   name                      = each.value.hub_virtual_network_name
#   parent_id                 = each.value.dataexp_virtual_network_id
#   type     = "Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2023-11-01"

#   # Optional resource attributes
#   body = {
#     properties = {
#       remoteVirtualNetwork = {
#         id = each.value.hub_virtual_network_id
#       }
#       allowVirtualNetworkAccess = true
#       allowForwardedTraffic     = false
#       allowGatewayTransit       = true
#       useRemoteGateways         = false
#     }
#   }
# }

# resource "azurerm_virtual_network_peering" "hubnetworking_to_dataexp" {
#   for_each = local.dataexp_hub_vnet_connections

#   # Mandatory resource attributes
#   name                      = each.value.dataexp_virtual_network_name
#   remote_virtual_network_id = each.value.dataexp_virtual_network_id
#   resource_group_name       = each.value.hub_resource_group_name
#   virtual_network_name      = each.value.hub_virtual_network_name  

#   provider = azurerm.connectivity
# }
