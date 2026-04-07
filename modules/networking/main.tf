# modules/networking/main.tf

# VNet
resource "azurerm_virtual_network" "virtual-network" {
  name                = var.vnet_name
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = var.vnet_address_space
}

# App Subnet
resource "azurerm_subnet" "app-subnet" {
  name                 = var.app_subnet_name
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.virtual-network.name
  address_prefixes     = var.app_subnet_prefixes
}

# Database Subnet
resource "azurerm_subnet" "db-subnet" {
  name                 = var.db_subnet_name
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.virtual-network.name
  address_prefixes     = var.db_subnet_prefixes
}

# Network Security Group dla app subnet
resource "azurerm_network_security_group" "nsg-app" {
  name                = "nsg-app"
  location            = var.location
  resource_group_name = var.resource_group_name

  # Regula 1: HTTP z internetu
  security_rule {
    name                       = "allow-http"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # Regula 2: HTTPS z internetu
  security_rule {
    name                       = "allow-https-internet"
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # Regula 3: SSH z management subnet
  security_rule {
    name                       = "allow-ssh-management"
    priority                   = 102
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefixes    = [var.management_subnet_prefix]
    destination_address_prefix = "*"
  }

  # Regula 4: Outbound do db-subnet (SQL)
  security_rule {
    name                       = "allow-to-db"
    priority                   = 200
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = var.db_port
    source_address_prefix      = "VirtualNetwork" 
    destination_address_prefix = var.db_subnet_prefixes[0]
  }
}

# Network Security Group dla db subnet
resource "azurerm_network_security_group" "nsg-db" {
  name                = "nsg-db"
  location            = var.location
  resource_group_name = var.resource_group_name

  # Regula 1: SQL z app-subnet
  security_rule {
    name                       = "allow-sql-from-app"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = var.db_port
    source_address_prefixes    = var.app_subnet_prefixes
    destination_address_prefix = "*"
  }

  # Regula 2: SSH z management subnet
  security_rule {
    name                       = "allow-ssh-management"
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefixes    = [var.management_subnet_prefix]
    destination_address_prefix = "*"
  }
}

# Powiązanie NSG z subnetami
resource "azurerm_subnet_network_security_group_association" "app" {
  subnet_id                 = azurerm_subnet.app-subnet.id
  network_security_group_id = azurerm_network_security_group.nsg-app.id
}

resource "azurerm_subnet_network_security_group_association" "db" {
  subnet_id                 = azurerm_subnet.db-subnet.id
  network_security_group_id = azurerm_network_security_group.nsg-db.id
}

resource "azurerm_public_ip" "lb_ip" {
  name                = "lb-ip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_lb" "lb" {
  name                = "app-lb"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "public-frontend"
    public_ip_address_id = azurerm_public_ip.lb_ip.id
  }
}

resource "azurerm_lb_backend_address_pool" "backend" {
  loadbalancer_id = azurerm_lb.lb.id
  name            = "backend-pool"
}

resource "azurerm_lb_probe" "http" {
  loadbalancer_id = azurerm_lb.lb.id
  name            = "http-probe"
  protocol        = "Http"
  port            = 80
  request_path    = "/"
}

resource "azurerm_lb_rule" "http" {
  loadbalancer_id                = azurerm_lb.lb.id
  name                           = "http-rule"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "public-frontend"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.backend.id]
  probe_id                       = azurerm_lb_probe.http.id
}