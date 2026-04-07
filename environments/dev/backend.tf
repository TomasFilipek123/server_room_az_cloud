terraform {
  backend "azurerm" {
    resource_group_name  = "terraform-state-rg"
    storage_account_name = "tfstate1232137"
    container_name       = "tfstate"
    key                  = "dev/terraform.tfstate"
  }
}