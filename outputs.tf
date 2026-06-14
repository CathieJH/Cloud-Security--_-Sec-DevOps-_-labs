output "gateway_public_ip" {
  description = "Public IP of the VPN gateway"
  value       = azurerm_public_ip.vpn.ip_address
}

output "gateway_id" {
  description = "ID of the VPN gateway"
  value       = azurerm_virtual_network_gateway.vpn.id
}
