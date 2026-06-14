# =============================================================================
# VPN MODULE
# A point-to-site (P2S) VPN gateway in the hub's GatewaySubnet.
# P2S is cheaper and easier to demo than site-to-site (no on-prem device
# required). See the commented block at the bottom for how to convert to S2S.
#
# COST WARNING: a VPN gateway bills per hour even when idle (~£20-30/day for
# the VpnGw1 SKU). Deploy, screenshot, then run the teardown script.
# =============================================================================

# Public IP for the gateway.
resource "azurerm_public_ip" "vpn" {
  name                = "${var.prefix}-vpngw-pip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

resource "azurerm_virtual_network_gateway" "vpn" {
  name                = "${var.prefix}-vpngw"
  location            = var.location
  resource_group_name = var.resource_group_name

  type     = "Vpn"
  vpn_type = "RouteBased"
  sku      = var.gateway_sku

  ip_configuration {
    name                          = "vnetGatewayConfig"
    public_ip_address_id          = azurerm_public_ip.vpn.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = var.gateway_subnet_id
  }

  # Point-to-site config using Azure AD / Entra ID authentication.
  # This ties the VPN directly to Entra ID - the IAM platform the role centres
  # on - so only Conditional-Access-governed identities can connect.
  vpn_client_configuration {
    address_space = [var.vpn_client_pool]

    # Entra ID (Azure AD) authentication.
    aad_tenant   = var.aad_tenant_url
    aad_audience = var.aad_audience
    aad_issuer   = var.aad_issuer

    vpn_client_protocols = ["OpenVPN"]
  }

  tags = var.tags
}

# -----------------------------------------------------------------------------
# CONVERTING TO SITE-TO-SITE (S2S):
# Replace the vpn_client_configuration above with the two resources below,
# which represent the on-prem device and the encrypted tunnel to it.
#
# resource "azurerm_local_network_gateway" "onprem" {
#   name                = "${var.prefix}-onprem-lng"
#   location            = var.location
#   resource_group_name = var.resource_group_name
#   gateway_address     = var.onprem_public_ip   # public IP of on-prem router
#   address_space       = [var.onprem_address_space]
# }
#
# resource "azurerm_virtual_network_gateway_connection" "s2s" {
#   name                       = "${var.prefix}-s2s-conn"
#   location                   = var.location
#   resource_group_name        = var.resource_group_name
#   type                       = "IPsec"
#   virtual_network_gateway_id = azurerm_virtual_network_gateway.vpn.id
#   local_network_gateway_id   = azurerm_local_network_gateway.onprem.id
#   shared_key                 = var.s2s_shared_key   # store in a secret, never in code
# }
# -----------------------------------------------------------------------------
