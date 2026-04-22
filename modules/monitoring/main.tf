# 1. Tworzymy magazyn na logi i metryki
resource "azurerm_log_analytics_workspace" "law" {
  name                = "law-${var.env_name}"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

# 2. Instalujemy agenta monitoringu na maszynach APP (pętla count)
resource "azurerm_virtual_machine_extension" "monitor_app" {
  count                      = var.app_vm_count
  name                       = "OmsAgentForLinux" # Zmiana nazwy
  virtual_machine_id         = var.app_vm_ids[count.index]
  publisher                  = "Microsoft.EnterpriseCloud.Monitoring"
  type                       = "OmsAgentForLinux"   # KLUCZOWA ZMIANA: Z MMA na OmsAgent
  type_handler_version       = "1.13"               # KLUCZOWA ZMIANA: Wersja dla Linuxa
  auto_upgrade_minor_version = true

  settings = <<SETTINGS
    {
      "workspaceId": "${azurerm_log_analytics_workspace.law.workspace_id}"
    }
  SETTINGS

  protected_settings = <<PROTECTED_SETTINGS
    {
      "workspaceKey": "${azurerm_log_analytics_workspace.law.primary_shared_key}"
    }
  PROTECTED_SETTINGS
}

# 3. To samo dla maszyny DB
resource "azurerm_virtual_machine_extension" "monitor_db" {
  name                       = "OmsAgentForLinux-DB"
  virtual_machine_id         = var.db_vm_id
  publisher                  = "Microsoft.EnterpriseCloud.Monitoring"
  type                       = "OmsAgentForLinux"   # KLUCZOWA ZMIANA
  type_handler_version       = "1.13"               # KLUCZOWA ZMIANA
  auto_upgrade_minor_version = true

  settings = <<SETTINGS
    {
      "workspaceId": "${azurerm_log_analytics_workspace.law.workspace_id}"
    }
  SETTINGS

  protected_settings = <<PROTECTED_SETTINGS
    {
      "workspaceKey": "${azurerm_log_analytics_workspace.law.primary_shared_key}"
    }
  PROTECTED_SETTINGS
}