resource "azurerm_availability_set" "app_as" {
  name                = "${var.environment}-app-as"
  location            = var.location
  resource_group_name = var.resource_group_name
  managed             = true

  platform_fault_domain_count  = 2
  platform_update_domain_count = 2
}

resource "azurerm_network_interface" "app_nic" {
  count               = 2
  name                = "${var.environment}-app-nic-${count.index}"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.app_subnet_id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "app_vm" {
  count               = 2
  name                = "${var.environment}-vm-app-${count.index}"
  resource_group_name = var.resource_group_name
  location            = var.location
  size                = "Standard_B2s_v2"
  admin_username      = var.admin_username
  availability_set_id = azurerm_availability_set.app_as.id
  
  network_interface_ids = [
    azurerm_network_interface.app_nic[count.index].id,
  ]

  admin_ssh_key {
    username   = var.admin_username
    public_key = var.ssh_public_key
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}

resource "azurerm_network_interface" "db_nic" {
  name                = "${var.environment}-db-nic"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.db_subnet_id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "db_vm" {
  name                = "${var.environment}-vm-db"
  resource_group_name = var.resource_group_name
  location            = var.location
  size                = "Standard_B2s_v2"
  admin_username      = var.admin_username
  
  network_interface_ids = [
    azurerm_network_interface.db_nic.id,
  ]

  admin_ssh_key {
    username   = var.admin_username
    public_key = var.ssh_public_key
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}