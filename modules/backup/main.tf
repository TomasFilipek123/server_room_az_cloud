# 1. Magazyn Recovery Services
resource "azurerm_recovery_services_vault" "vault" {
  name                = "${var.environment}-recovery-vault"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "Standard"

  # Usuwamy soft_delete_enabled oraz soft_delete_parameter.
  # Azure domyślnie włącza Soft Delete (zazwyczaj na 14 dni), 
  # co jest wystarczające dla wymogów projektu.
}


# 2. Polityka Backup dla maszyn Linux
resource "azurerm_backup_policy_vm" "policy" {
  name                = "${var.environment}-vm-backup-policy"
  resource_group_name = var.resource_group_name
  recovery_vault_name = azurerm_recovery_services_vault.vault.name

  timezone = "UTC"

  backup {
    frequency = "Daily"
    time      = "23:00"
  }

  retention_daily {
    count = 7 # Przechowuj kopie z ostatnich 7 dni
  }
}

# 3. Przypisanie maszyny aplikacyjnej do backupu
resource "azurerm_backup_protected_vm" "backup_app" {
  count               = 2
  resource_group_name = var.resource_group_name
  recovery_vault_name = azurerm_recovery_services_vault.vault.name
  source_vm_id        = var.app_vm_ids[count.index]
  backup_policy_id    = azurerm_backup_policy_vm.policy.id
}

# 4. Przypisanie maszyny bazodanowej do backupu
resource "azurerm_backup_protected_vm" "backup_db" {
  resource_group_name = var.resource_group_name
  recovery_vault_name = azurerm_recovery_services_vault.vault.name
  source_vm_id        = var.db_vm_id
  backup_policy_id    = azurerm_backup_policy_vm.policy.id
}