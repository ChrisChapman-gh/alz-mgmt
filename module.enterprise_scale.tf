locals {
  # read the enterprise scale settings from the settings file if it exists
  enterprise_scale_config = try(yamldecode(file("${path.module}/settings.enterprise_scale.yml")), {})

  # DataEXP requires a Corp Landing Zone
  corp_landing_zones_required = var.accelerator_dataexp_enabled

  # Generate a map of the subscriptions the LZ should manage
  corp_override = distinct(compact(concat(try(local.enterprise_scale_config.subscription_id_overrides.corp, []), local.dataexp_subscription_ids)))
  subscription_id_overrides = { for k, v in
    merge(try(local.enterprise_scale_config.subscription_id_overrides, {}), {
      corp = length(local.corp_override) != 0 ? local.corp_override : null
      # sandboxes = length(local.corp_override) != 0 ? local.corp_override : null
    })
  : k => v if v != null }
}

module "enterprise_scale" {
  source  = "Azure/caf-enterprise-scale/azurerm"
  version = "~> 5.2.0"

  # Mandatory resource attributes
  default_location = var.default_location
  root_parent_id   = try(local.enterprise_scale_config.root_parent_management_group_id, data.azurerm_client_config.current.tenant_id)

  # Optional resource attributes
  deploy_corp_landing_zones = local.corp_landing_zones_required
  # - None of the current accelerators require the deployment of the identity resources
  deploy_identity_resources = false
  # - Management resources such as Log Analytics must always be deployed
  deploy_management_resources = true
  # - None of the current accelerators require the deployment of the online landing zones
  deploy_online_landing_zones = false
  disable_telemetry           = try(local.enterprise_scale_config.disable_telemetry, true)
  root_id                     = local.enterprise_scale_config.root_id
  root_name                   = local.enterprise_scale_config.root_name
  # - Corp requires connectivity
  subscription_id_connectivity = local.corp_landing_zones_required ? var.subscription_id_connectivity : null
  subscription_id_management   = var.subscription_id_management
  subscription_id_overrides    = local.subscription_id_overrides

  providers = {
    azurerm              = azurerm
    azurerm.connectivity = azurerm.connectivity
    azurerm.management   = azurerm.management
  }
}
