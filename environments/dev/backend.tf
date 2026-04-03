terraform {
    backend "azurerm" {
        resource_group_name     = "terraform-state"
        storage_account_type    = "tfstate123"
        container_name          = "tfstate"
        key                     = "dev/terraform.tfstate"
    }
}