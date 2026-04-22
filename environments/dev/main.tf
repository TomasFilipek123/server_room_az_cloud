# Resource group
resource "azurerm_resource_group" "main" {
  name     = "${var.environment}-${var.project}-rg"
  location = var.location
}

module "networking" {
  source              = "../../modules/networking"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  environment         = var.environment 
  
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
  location            = azurerm_resource_group.main.location
  environment         = var.environment
  app_subnet_id       = module.networking.app_subnet_id
  db_subnet_id        = module.networking.db_subnet_id
  admin_username      = var.admin_username
  ssh_public_key      = var.ssh_public_key
  app_vm_size         = var.app_vm_size
  db_vm_size          = var.db_vm_size
  depends_on = [module.networking]
}

module "backup" {
  source              = "../../modules/backup"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  environment         = var.environment
  app_vm_ids           = module.compute.app_vm_ids
  db_vm_id           = module.compute.db_vm_id

  depends_on = [module.compute] # Backup musi poczekać, aż VM-ki powstaną
}

module "monitoring" {
  source              = "../../modules/monitoring"
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
  env_name            = var.env_name
  app_vm_ids          = module.compute.app_vm_ids
  db_vm_id            = module.compute.db_vm_id
  app_vm_count        = 2
}

resource "azurerm_network_interface_backend_address_pool_association" "app_lb_assoc" {
  count                   = 2
  network_interface_id    = module.compute.app_nic_ids[count.index]
  ip_configuration_name   = "internal"
  backend_address_pool_id = module.networking.lb_backend_address_pool_id
}

