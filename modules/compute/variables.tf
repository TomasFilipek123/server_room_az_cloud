variable "location"{
  description = "location of the resources"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, prod)"
  type        = string
  default     = "dev"
}

# Subnet ids z modulu networking
variable "app_subnet_id" {
  type = string
}

variable db_subnet_id {
  type = string
}

# VM konfiguracja
variable "admin_username" {
  description = "Admin username for VMs"
  type        = string 
  sensitive   = true
}

variable "ssh_public_key" {
  description = "SSH public key for VM access"
  type        = string
  sensitive   = true
}

variable "app_vm_size" {
  description = "Size of the application VM"
  type        = string
  default     = "Standard_D2s_v3"
}

variable "db_vm_size" {
  description = "Size of the database VM"
  type        = string
  default     = "Standard_D2s_v3"
}

variable "create_public_ip" {
  description = "Whether to create public IP for app VM"
  type        = bool
  default     = true
}

variable "backend_pool_id" {
  type = string
}