provider "azurerm" {
  features {}
}
resource "azurerm_resource_group" "rg" {
        name = "terraform"
        location = "eastasia"
}
