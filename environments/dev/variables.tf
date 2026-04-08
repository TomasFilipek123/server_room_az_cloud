variable "environment" {
  type    = string
  default = "dev"
}

variable "project" {
  type    = string
  default = "server-room"
}

variable "location" {
  type    = string
  default = "swedencentral"
}

variable "admin_username" {
  description = "Admin username for VMs"
  type        = string
  sensitive   = true
}

variable "ssh_public_key" {
  description = "SSH key for VM access"
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


