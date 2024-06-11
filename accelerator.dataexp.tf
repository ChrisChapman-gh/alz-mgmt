# Resources required for the DataEXP accelerator
locals {
  dataexp_config = try(yamldecode(file("${path.module}/settings.dataexp.yml")), {})
  # Generate a list of subscription ids for enterprise_scale module
  dataexp_subscription_ids = [for sub in try(local.dataexp_config.subscriptions, {}) : sub.id]
  # Generate a map of all the instances for all the subscriptions
  # dataexp_instances = { for instance in flatten([
  #   for subscription in try(local.dataexp_config.subscriptions, {}) : [
  #     for instance_k, instance_v in try(subscription.instances, {}) : {
  #       key             = "${subscription.id}-${instance_k}"
  #       subscription_id = subscription.id
  #       instance_name   = instance_k
  #       config          = instance_v
  #     }
  #   ]
  # ]) : instance.key => instance }
}

# # Create Resource Groups
# resource "azapi_resource" "dataexp_rg" {
#   for_each = var.accelerator_dataexp_enabled ? local.dataexp_instances : {}

#   # Mandatory resource attributes
#   name      = coalesce(try(each.value.config.virtual_network_resource_group_name, ""), "rg-${each.value.instance_name}-spoke-01")
#   parent_id = "/subscriptions/${each.value.subscription_id}"
#   type      = "Microsoft.Resources/resourceGroups@2021-04-01"

#   # Optional resource attributes
#   location = try(each.value.config.location, var.default_location)
# }

# # Create vNets
# module "dataexp_vnet" {
#   source   = "Azure/avm-res-network-virtualnetwork/azurerm"
#   version  = "~> 0.2.0"
#   for_each = var.accelerator_dataexp_enabled ? local.dataexp_instances : {}

#   # Mandatory resource attributes
#   address_space       = toset([each.value.config.address_space])
#   location            = azapi_resource.dataexp_rg[each.key].location
#   resource_group_name = azapi_resource.dataexp_rg[each.key].name

#   # Optional resource attributes
#   enable_telemetry = false # module does not support telemetry via azapi
#   name             = coalesce(try(each.value.config.virtual_network_name, ""), "vnet-${each.value.instance_name}-spoke-01")
#   subscription_id  = each.value.subscription_id
# }

# # Create Route table if using hubnetworking
# resource "azapi_resource" "dataexp_route_table" {
#   for_each = var.accelerator_dataexp_enabled && !var.virtual_wan_enabled ? local.dataexp_instances : {}

#   # Mandatory resource attributes
#   name      = coalesce(try(each.value.config.route_table_name, ""), "rt-${each.value.instance_name}-spoke-01")
#   parent_id = azapi_resource.dataexp_rg[each.key].id
#   type      = "Microsoft.Network/routeTables@2021-02-01"

#   # Optional resource attributes
#   body = {
#     properties = {
#       disableBgpRoutePropagation = false
#       routes = [
#         {
#           name = "default-via-hub"
#           properties = {
#             addressPrefix   = "0.0.0.0/0"
#             nextHopType      = "VirtualAppliance"
#             nextHopIpAddress = module.hubnetworking[0].firewalls[each.value.config.network_hub].private_ip_address
#           }
#         }
#       ]
#     }
#   }
#   location = azapi_resource.dataexp_rg[each.key].location  
# }
