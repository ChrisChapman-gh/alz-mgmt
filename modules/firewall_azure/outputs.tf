output "firewall_config" {
  value = { for k, v in local.firewalls : k => v if v != null }
  description = "Generated firewall configuration"
}

output "routing_intents" {
  value = local.routing_intents
  description = "Generated routing intents" 
}