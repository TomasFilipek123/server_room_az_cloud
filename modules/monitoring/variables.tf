variable "location" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "env_name" {
  type = string
}

variable "app_vm_ids" {
  type = list(string)
}

variable "db_vm_id" {
  type = string
}

variable "app_vm_count" {
  type = number
}