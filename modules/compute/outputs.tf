output "app_vm_id" {
  description = "ID of the application VM"
  value       = azurerm_linux_virtual_machine.app_vm.id
}

output "db_vm_id" {
  description = "ID of the database VM"
  value       = azurerm_linux_virtual_machine.db_vm.id
}

output "app_vm_private_ip" {
  description = "Private IP address of the application VM"
  value       = azurerm_network_interface.app_nic.private_ip_address
}

output "db_vm_private_ip" {
  description = "Private IP address of the database VM"
  value       = azurerm_network_interface.db_nic.private_ip_address
}

output "app_vm_public_ip" {
  description = "Public IP address of the application VM"
  value       = azurerm_public_ip.vm_ip.ip_address
}

output "app_nic_id" {
  description = "ID of the application network interface"
  value       = azurerm_network_interface.app_nic.id
}

output "db_nic_id" {
  description = "ID of the database network interface"
  value       = azurerm_network_interface.db_nic.id
}