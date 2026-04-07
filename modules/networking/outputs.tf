# modules/networking/outputs.tf

output "vnet_id" {
  description = "ID of the virtual network"
  value       = azurerm_virtual_network.virtual-network.id
}

output "vnet_name" {
  description = "Name of the virtual network"
  value       = azurerm_virtual_network.virtual-network.name
}

output "app_subnet_id" {
  description = "ID of the application subnet"
  value       = azurerm_subnet.app-subnet.id
}

output "db_subnet_id" {
  description = "ID of the database subnet"
  value       = azurerm_subnet.db-subnet.id
}

output "nsg_app_id" {
  description = "ID of the app NSG"
  value       = azurerm_network_security_group.nsg-app.id
}

output "nsg_db_id" {
  description = "ID of the database NSG"
  value       = azurerm_network_security_group.nsg-db.id
}


output "backend_pool_id" {
  value = azurerm_lb_backend_address_pool.backend.id
}