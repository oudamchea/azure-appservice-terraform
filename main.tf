locals {
  projects_map = { for project in var.projects : project.name => project }
}

module "webapp" {
  for_each = local.projects_map
  source   = "./modules/webapp"

  project_name = each.value.name
  location     = length(trimspace(try(each.value.location, ""))) > 0 ? each.value.location : var.location

  create_resource_group = try(each.value.create_resource_group, true)
  resource_group_name   = length(trimspace(try(each.value.resource_group_name, ""))) > 0 ? each.value.resource_group_name : "${lower(terraform.workspace)}-${each.value.name}-rg"

  sku_tier = try(each.value.sku_tier, "Standard")
  sku_size = try(each.value.sku_size, "B1")

  linux_fx_version = try(each.value.linux_fx_version, "")
  app_settings = merge(
    { "ENV" = lower(terraform.workspace) },
    try(each.value.app_settings, {})
  )

  docker_image    = try(each.value.docker_image, "")
  docker_registry = try(each.value.docker_registry, {})
  tags            = merge(var.tags, { Environment = lower(terraform.workspace) })

  # Kept for compatibility with future package-based deployments.
  # Current deployment pattern uses Docker images only.
  run_from_package = try(each.value.run_from_package, false)
}
