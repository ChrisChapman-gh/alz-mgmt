locals {
  #Generate Azure Firewall Config
  firewalls = { for k, v in var.firewalls : k => {
    sku_name           = var.vwan_enabled ? "AZFW_Hub" : "AZFW_VNet"
    sku_tier           = var.sku_tier
    name               = v.name
    virtual_hub_key    = var.vwan_enabled ? k : null
    zones              = !var.vwan_enabled ? var.regions_by_name[v.location].zones : null
    firewall_policy_id = azurerm_firewall_policy.this.id
    }
  }

  #Generate routing intent Config
  routing_intents_private = { for k, v in var.firewalls : "${k}-private" => {
    name            = "${k}-private"
    virtual_hub_key = k
    routing_policies = [{
      name                  = "PrivateTrafficPolicy"
      destinations          = ["PrivateTraffic"]
      next_hop_firewall_key = k
    }]
    }
  }
  routing_intents_internet = { for k, v in var.firewalls : "${k}-internet" => {
    name            = "${k}-internet"
    virtual_hub_key = k
    routing_policies = [{
      name                  = "InternetTrafficPolicy"
      destinations          = ["Internet"]
      next_hop_firewall_key = k
    }]
    }
  }
  routing_intents = merge(local.routing_intents_private, local.routing_intents_internet)
}
