# modules/compute/outputs.tf

# Zwraca listę ID wszystkich maszyn aplikacyjnych (potrzebne do modułu Backup)
output "app_vm_ids" {
  description = "Lista ID maszyn wirtualnych aplikacji"
  value       = azurerm_linux_virtual_machine.app_vm[*].id
}

# Zwraca listę ID interfejsów sieciowych aplikacji (potrzebne do podpięcia pod Load Balancer)
output "app_nic_ids" {
  description = "Lista ID interfejsów sieciowych maszyn aplikacji"
  value       = azurerm_network_interface.app_nic[*].id
}

# Zwraca listę prywatnych adresów IP maszyn aplikacji
output "app_vm_private_ips" {
  description = "Prywatne adresy IP maszyn aplikacji"
  value       = azurerm_linux_virtual_machine.app_vm[*].private_ip_address
}

# Zwraca ID maszyny bazy danych
output "db_vm_id" {
  description = "ID maszyny wirtualnej bazy danych"
  value       = azurerm_linux_virtual_machine.db_vm.id
}

# Zwraca prywatny adres IP bazy danych
output "db_vm_private_ip" {
  description = "Prywatny adres IP bazy danych"
  value       = azurerm_linux_virtual_machine.db_vm.private_ip_address
}


