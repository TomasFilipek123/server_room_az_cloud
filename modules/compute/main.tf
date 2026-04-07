resource "azurerm_public_ip" "vm_ip" {
  name                = "${var.environment}-app-ip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_network_interface_backend_address_pool_association" "app" {
  network_interface_id    = azurerm_network_interface.app_nic.id
  ip_configuration_name   = "internal"
  backend_address_pool_id = var.backend_pool_id
}

resource "azurerm_network_interface" "app_nic" {
  name                = "${var.environment}-app-nic"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.app_subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.vm_ip.id
  }
}

resource "azurerm_linux_virtual_machine" "app_vm" {
  name                = "${var.environment}-vm-app"
  resource_group_name = var.resource_group_name
  location            = var.location
  size                = var.app_vm_size
  admin_username      = var.admin_username

  network_interface_ids = [
    azurerm_network_interface.app_nic.id
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

    tags = {
    environment = var.environment
    role        = "application"
    managed_by  = "terraform"
  }
}


resource "azurerm_network_interface" "db_nic" {
  name                = "db-nic"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.db_subnet_id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "db_vm" {
  name                = "vm-db"
  resource_group_name = var.resource_group_name
  location            = var.location
  size                = "Standard_D2s_v3"

  admin_username = var.admin_username

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
  
    tags = {
    environment = var.environment
    role        = "database"
    managed_by  = "terraform"
  }
}