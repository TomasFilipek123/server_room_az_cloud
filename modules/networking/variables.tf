# modules/networking/variables.tf

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region where resources will be created"
  type        = string
}


variable "vnet_name" {
  description = "Name of the virtual network"
  type        = string
  default     = "virtual-network"
}

variable "vnet_address_space" {
  description = "Address space for the virtual network"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}


variable "app_subnet_name" {
  description = "Name of the application subnet"
  type        = string
  default     = "app-subnet"
}

variable "app_subnet_prefixes" {
  description = "Address prefixes for application subnet"
  type        = list(string)
  default     = ["10.0.1.0/24"]
}

variable "db_subnet_name" {
  description = "Name of the database subnet"
  type        = string
  default     = "db-subnet"
}

variable "db_subnet_prefixes" {
  description = "Address prefixes for database subnet"
  type        = list(string)
  default     = ["10.0.2.0/24"]
}

variable "management_subnet_prefix" {
  description = "Address prefix for management subnet (for SSH access)"
  type        = string
  default     = "10.0.3.0/28"
}

variable "db_port" {
  description = "Database port (e.g., 1433 for SQL, 3306 for MySQL)"
  type        = number
  default     = 1433
}

