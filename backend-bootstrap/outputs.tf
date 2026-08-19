output "resource_group_name" {
  description = "Name of the resource group"
  value       = azurerm_resource_group.backend.name
}

output "storage_account_name" {
  description = "Name of the storage account"
  value       = azurerm_storage_account.backend.name
}

output "storage_container_name" {
  description = "Name of the storage container"
  value       = azurerm_storage_container.backend.container_access_type
}

output "backend_config" {
  description = "Backend configuration values"
  value = {
    resource_group_name  = azurerm_resource_group.backend.name
    storage_account_name = azurerm_storage_account.backend.name
    container_name       = azurerm_storage_container.backend.name
    key                  = "azure-webapp-${var.environment}.tfstate"
  }
}
