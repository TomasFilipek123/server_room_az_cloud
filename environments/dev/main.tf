# Resource group
resource "azurerm_resource_group" "main" {
  name     = "${var.environment}-${var.project}-rg"
  location = var.location
}

module "networking" {
  source              = "../../modules/networking"
  resource_group_name = azurerm_resource_group.main.name
  location            = var.location
  vnet_name           = "${var.environment}-vnet"
  vnet_address_space  = ["10.0.0.0/16"]
  app_subnet_name     = "${var.environment}-app-subnet"
  app_subnet_prefixes = ["10.0.1.0/24"]
  db_subnet_name      = "${var.environment}-db-subnet"
  db_subnet_prefixes  = ["10.0.2.0/24"]
}

module "compute" {
  source              = "../../modules/compute"
  resource_group_name = azurerm_resource_group.main.name
  location            = var.location
  environment         = var.environment
  app_subnet_id       = module.networking.app_subnet_id
  db_subnet_id        = module.networking.db_subnet_id
  admin_username      = var.admin_username
  ssh_public_key      = var.ssh_public_key
  app_vm_size         = var.app_vm_size
  db_vm_size          = var.db_vm_size
  backend_pool_id     = module.networking.backend_pool_id
}