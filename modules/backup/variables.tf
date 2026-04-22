variable "resource_group_name" { type = string }
variable "location"            { type = string }
variable "environment"         { type = string }
variable "app_vm_ids" {
  type        = list(string)
  description = "Lista ID maszyn do backupu"
}

variable "db_vm_id" {
  type        = string
}