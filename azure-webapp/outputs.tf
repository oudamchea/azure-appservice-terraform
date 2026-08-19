output "webapp_hostnames" {
  description = "Map of project name -> default site hostname"
  value       = { for k, m in module.webapp : k => m.app_default_site_hostname }
}

output "webapp_urls" {
  description = "Map of project name -> https url"
  value       = { for k, h in module.webapp : k => "https://${h.app_default_site_hostname}" }
}
