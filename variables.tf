variable "prefix" {
  type        = string
  description = "Naming prefix"
}

variable "location" {
  type        = string
  description = "Azure region"
}

variable "resource_group_name" {
  type        = string
  description = "Resource group name"
}

variable "tags" {
  type        = map(string)
  description = "Resource tags"
}

variable "gateway_subnet_id" {
  type        = string
  description = "ID of the GatewaySubnet"
}

variable "gateway_sku" {
  type        = string
  description = "VPN gateway SKU. VpnGw1 is the cheapest production-grade SKU."
  default     = "VpnGw1"
}

variable "vpn_client_pool" {
  type        = string
  description = "Address pool handed to P2S VPN clients"
  default     = "172.16.0.0/24"
}

# Entra ID (Azure AD) authentication values.
# tenant URL form: https://login.microsoftonline.com/<tenant-id>/
# For Azure VPN client the audience is the well-known Azure VPN app ID.
variable "aad_tenant_url" {
  type        = string
  description = "Entra ID tenant login URL"
}

variable "aad_audience" {
  type        = string
  description = "Azure VPN application ID (audience)"
  default     = "41b23e61-6c1e-4545-b367-cd054e0ed4b4"
}

variable "aad_issuer" {
  type        = string
  description = "Entra ID issuer URL (https://sts.windows.net/<tenant-id>/)"
}
