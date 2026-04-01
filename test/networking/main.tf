# test/networking/main.tf

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "test-networking-rg"
  location = "polandcentral"
}

module "networking" {
  source = "../../modules/networking"
  
  # Teraz te zmienne są zdefiniowane!
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  vnet_name           = "test-vnet"
  vnet_address_space  = ["10.0.0.0/16"]
  app_subnet_name     = "test-app-subnet"
  app_subnet_prefixes = ["10.0.1.0/24"]
  db_subnet_name      = "test-db-subnet"
  db_subnet_prefixes  = ["10.0.2.0/24"]
}

output "vnet_id" {
  value = module.networking.vnet_id
}
