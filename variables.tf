variable "default_location" {
  type        = string
  description = "The location for Azure resources.|1|azure_location"
}

variable "subscription_id_connectivity" {
  type        = string
  description = "The identifier of the Connectivity Subscription."
}

# variable "subscription_id_identity" {
#   type        = string
#   description = "The identifier of the Identity Subscription. (e.g '00000000-0000-0000-0000-000000000000')|4|azure_subscription_id"
# }

variable "subscription_id_management" {
  type        = string
  description = "The identifier of the Management Subscription.|5|azure_subscription_id"
}

variable "accelerator_dataexp_enabled" {
  type        = bool
  default     = false
  description = "Enable the DataEXP accelerator"
}

variable "virtual_wan_enabled" {
  type        = bool
  default     = true
  description = "Enable Virtual WAN as the core connectivity service instead of Hub&Spoke."
}

variable "azure_firewall_enabled" {
  type        = bool
  default     = true
  description = "Enable Azure Firewall as the core security service"
}