resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-${var.client_code}"
  location            = azurerm_resource_group.net.location
  resource_group_name = azurerm_resource_group.net.name
  address_space       = ["10.0.0.0/16"]
}