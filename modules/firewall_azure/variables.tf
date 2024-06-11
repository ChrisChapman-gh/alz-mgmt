# Resource group parameters
variable "location" {
  type        = string
  description = "The Azure firewall Resource group location"
  nullable    = false

  validation {
    condition     = length(var.location) > 0
    error_message = "Resource group location must be specified."
  }
}

variable "resource_group_name" {
  type        = string
  description = "The Azure firewall Resource group name"
  nullable    = false

  validation {
    condition     = length(var.resource_group_name) > 0
    error_message = "Resource group name must be specified."
  }
}

variable "policy_name" {
  type        = string
  description = "The name for the Azure Firewall policy"
  nullable    = false

  validation {
    condition     = length(var.policy_name) > 0
    error_message = "Policy name must be specified."
  }
}

variable "regions_by_name" {
  type = map(object({
    zones = list(number)
  }))
  description = "A map of regions by name"
}

variable "sku_tier" {
  type = string
  description = "The Azure firewall SKU tier"
  default = "Standard"
  nullable = false
}

variable "firewalls" {
  type        = map(any)
  description = "The Azure firewall configuration"
  nullable    = false
  default     = {}
}

variable "vwan_enabled" {
  type        = bool
  description = "Configure firewalls for Virtual WAN instead of Hub&Spoke."
  default     = true
  nullable    = false
}
