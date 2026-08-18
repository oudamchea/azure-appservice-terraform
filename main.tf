locals {
  projects_map = { for p in var.projects : p.name => p }
}

module "webapp" {
  for_each = local.projects_map
  source   = "./modules/webapp"

  project_name          = each.value.name
  location              = try(each.value.location, null) != null ? try(each.value.location, var.location) : var.location
  create_resource_group = try(each.value.create_resource_group, null) != null ? try(each.value.create_resource_group, true) : true
  resource_group_name   = try(each.value.resource_group_name, null) != null ? try(each.value.resource_group_name, "") : "${lower(terraform.workspace)}-${each.value.name}-rg"
  sku_tier              = try(each.value.sku_tier, null) != null ? try(each.value.sku_tier, "Standard") : "Standard"
  sku_size              = try(each.value.sku_size, null) != null ? try(each.value.sku_size, "S1") : "S1"
  linux_fx_version      = try(each.value.linux_fx_version, null) != null ? try(each.value.linux_fx_version, "") : ""
  app_settings = merge(
    { "ENV" = lower(terraform.workspace) },
    try(each.value.app_settings, {})
  )
  docker_image     = try(each.value.docker_image, "")
  docker_registry  = try(each.value.docker_registry, {})
  tags             = merge(var.tags, { Environment = lower(terraform.workspace) })
  run_from_package = try(each.value.run_from_package, null) != null ? try(each.value.run_from_package, true) : true
}
