# Co wyświetlić po apply
output "resource_group_name" {
  value = azurerm_resource_group.main.name
}

output "vnet_id" {
  value = module.networking.vnet_id
}

output "app_vm_public_ip" {
  value = module.compute.app_vm_public_ip
}

