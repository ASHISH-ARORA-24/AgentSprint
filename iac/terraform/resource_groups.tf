provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "net" {
  name     = "rg-${var.client_code}-net"
  location = var.location
}

resource "azurerm_resource_group" "core" {
  name     = "rg-${var.client_code}-core"
  location = var.location
}

resource "azurerm_resource_group" "agent" {
  name     = "rg-${var.client_code}-agent"
  location = var.location
}
