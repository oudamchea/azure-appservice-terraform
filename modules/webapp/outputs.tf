output "app_default_site_hostname" {
  description = "App default hostname (e.g. myapp.azurewebsites.net)"
  value       = local.is_windows ? azurerm_windows_web_app.app[0].default_hostname : azurerm_linux_web_app.app[0].default_hostname
}
