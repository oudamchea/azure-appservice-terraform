output "app_default_site_hostname" {
  description = "App default hostname (e.g. myapp.azurewebsites.net)"
  value       = azurerm_linux_web_app.app.default_hostname
}
