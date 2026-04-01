# VNet
resource "azurerm_virtual_network" "virtual-network" {
  name                = "virtual-network"
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = ["10.0.0.0/16"]
}

# App Subnet
resource "azurerm_subnet" "app-subnet" {
	name			= "app-subnet"
	resource_group_name	= var.resource_group_name
	virtual_network_name	= azurerm_virtual_network.virtual-network.name
	address_prefixes	= ["10.0.1.0/24"]
}

# Database Subnet
resource "azurerm_subnet" "db-subnet" {
        name                    = "db-subnet"
        resource_group_name     = var.resource_group_name
	virtual_network_name	= azurerm_virtual_network.virtual-network.name
        address_prefixes        = ["10.0.2.0/24"]
}

# Network Security Group dla app subnet
resource "azurerm_network_security_group" "nsg-app" {
	name			= "nsg-app"
	location		= var.location
	resource_group_name	= var.resource_group_name
	
	# Regula 1: HTTP z internetu
	security_rule {
		name				= "allow-http"
		priority			= 100
		direction			= "Inbound"
		access				= "Allow"
		protocol			= "Tcp"
		source_port_range		= "*"
		destination_port_range		= "80"
		source_address_prefixes		= ["*"]
		destination_address_prefix	= "*"
	}
	
	# Regula 2: HTTPS z internetu
	security_rule	{
		name                       = "allow-https-internet"
	        priority                   = 101
		direction                  = "Inbound"
		access                     = "Allow"
		protocol                   = "Tcp"
		source_port_range          = "*"
		destination_port_range     = "443"
		source_address_prefixes    = ["*"]
		destination_address_prefix = "*"
	}
	
	# Regula 3: SSH z management subnet
	security_rule {
		name				= "allow-ssh-management"
		priority			= 102
		direction			= "Inbound"
		access				= "Allow"
		protocol			= "Tcp"
		source_port_range		= "*"
		destination_port_range		= "22"
		source_address_prefixes		= ["10.0.3.0/28"]
		destination_address_prefix	= "*"
	}
	# Regula 4: Outbound do db-subnet (SQL)
	security_rule {
		name				= "allow_to_db"
		priority			= 200
		direction			= "Outbound"
		access				= "Allow"
		protocol			= "Tcp"
		source_port_range		= "*"
		destination_port_range		= "1433"
		source_address_prefixes		= ["*"]
		destination_address_prefix	= "10.0.2.0/24"
	}

}

resource "azurerm_network_security_group" "nsg-db" {
	name			= "nsg-db"
	location		= var.location
	resource_group_name	= var.resource_group_name

	# Regula 1: SQL z app-subnet
	security_rule {
		name				= "allow-sql-from-app"
		priority			= 100
		direction			= "Inbound"
		access				= "Allow"
		protocol			= "Tcp"
		source_port_range		= "*"
		destination_port_range		= "1433"
		source_address_prefixes		= ["10.0.1.0/24"]
		destination_address_prefix	= "*"
	}

	# Regula 2: SSH z management subnet (dla adminow)
	security_rule {
		    name                       = "allow-ssh-management"
		    priority                   = 101
		    direction                  = "Inbound"
		    access                     = "Allow"
		    protocol                   = "Tcp"
		    source_port_range          = "*"
		    destination_port_range     = "22"
		    source_address_prefixes    = ["10.0.3.0/28"]
		    destination_address_prefix = "*"
	}
	  # Reguła 3: Blokuj wszystko inne
	security_rule {
		    name                       = "deny-all-inbound"
		    priority                   = 4000
		    direction                  = "Inbound"
		    access                     = "Deny"
		    protocol                   = "*"
		    source_port_range          = "*"
		    destination_port_range     = "*"
		    source_address_prefixes    = ["*"]
		    destination_address_prefix = "*"
  }

}

# Powiązanie NSG z app-subnet
resource "azurerm_subnet_network_security_group_association" "app" {
	subnet_id			= azurerm_subnet.app-subnet.id
	network_security_group_id	= azurerm_network_security_group.nsg-app.id
}

# Powiązanie NSH z db-subnet
resource "azurerm_subnet_network_security_group_association" "db" {
	subnet_id			= azurerm_subnet.db-subnet.id
	network_security_group_id	= azurerm_network_security_group.nsg-db.id
}
