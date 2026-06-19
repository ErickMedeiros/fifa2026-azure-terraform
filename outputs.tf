output "resource_group_name" {
  value = azurerm_resource_group.main.name
}

output "frontend_public_ip" {
  value = azurerm_public_ip.front.ip_address
}

output "backend_public_ip" {
  value = azurerm_public_ip.back.ip_address
}

output "data_public_ip" {
  value = azurerm_public_ip.data.ip_address
}

output "frontend_private_ip" {
  value = azurerm_network_interface.front.private_ip_address
}

output "backend_private_ip" {
  value = azurerm_network_interface.back.private_ip_address
}

output "data_private_ip" {
  value = azurerm_network_interface.data.private_ip_address
}

output "app_url_http" {
  value = "http://${azurerm_public_ip.front.ip_address}"
}
