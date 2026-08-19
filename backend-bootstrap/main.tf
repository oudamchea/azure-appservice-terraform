resource "azurerm_resource_group" "backend" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

resource "azurerm_storage_account" "backend" {
  name                     = "oudamtfstate${var.environment}001"
  resource_group_name      = azurerm_resource_group.backend.name
  location                 = azurerm_resource_group.backend.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = var.tags
}

resource "azurerm_storage_container" "backend" {
  name                  = var.container_name
  storage_account_id    = azurerm_storage_account.backend.id
  container_access_type = "private"
}
