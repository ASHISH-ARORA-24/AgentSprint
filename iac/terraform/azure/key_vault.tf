data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "key_vault" {
  name                       = "key-vault-${var.client_code}"
  location                   = azurerm_resource_group.net.location
  resource_group_name        = azurerm_resource_group.net.name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "premium"
  soft_delete_retention_days = 7

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
      "Create",
      "Get",
    ]

    secret_permissions = [
      "Set",
      "Get",
      "Delete",
      "Purge",
      "Recover"
    ]
  }
}

resource "azurerm_key_vault_secret" "github_secret" {
  name         = "github-token"
  value        = "szechuan"
  key_vault_id = azurerm_key_vault.key_vault.id
}