locals {
  prefix          = lower(terraform.workspace)
  cleaned_project = lower(replace(trimspace(var.project_name != null ? var.project_name : ""), " ", "-"))
  app_name        = "${local.prefix}-${local.cleaned_project}"
  plan_name       = "${local.prefix}-${local.cleaned_project}-plan"

  create_rg = var.create_resource_group != null ? var.create_resource_group : true
  rg_name = local.create_rg ? (
    length(trimspace(var.resource_group_name != null ? var.resource_group_name : "")) > 0 ? (
      startswith(var.resource_group_name != null ? var.resource_group_name : "", "${local.prefix}-") ? (var.resource_group_name != null ? var.resource_group_name : "") : "${local.prefix}-${var.resource_group_name != null ? var.resource_group_name : ""}"
    ) : "${local.prefix}-${local.cleaned_project}-rg"
  ) : (var.resource_group_name != null ? var.resource_group_name : "")

  normalized_linux_fx     = lower(trimspace(var.linux_fx_version != null ? var.linux_fx_version : ""))
  normalized_docker_image = trimspace(var.docker_image != null ? var.docker_image : "")
  is_windows              = lower(var.os_type) == "windows"
  runtime_version         = try(split("|", local.normalized_linux_fx)[1], "")
  windows_dotnet_version  = startswith(local.runtime_version, "v") ? local.runtime_version : "v${local.runtime_version}"
}

resource "azurerm_resource_group" "rg" {
  count    = var.create_resource_group ? 1 : 0
  name     = local.rg_name
  location = var.location
  tags     = var.tags
}

resource "azurerm_service_plan" "plan" {
  name                = local.plan_name
  location            = var.location
  resource_group_name = var.create_resource_group ? azurerm_resource_group.rg[0].name : var.resource_group_name
  os_type             = local.is_windows ? "Windows" : "Linux"
  sku_name            = var.sku_size
  tags                = var.tags
}

resource "azurerm_linux_web_app" "app" {
  count               = local.is_windows ? 0 : 1
  name                = local.app_name
  location            = var.location
  resource_group_name = var.create_resource_group ? azurerm_resource_group.rg[0].name : var.resource_group_name
  service_plan_id     = azurerm_service_plan.plan.id

  site_config {
    always_on = true

    application_stack {
      docker_image_name        = local.normalized_docker_image != "" ? local.normalized_docker_image : null
      docker_registry_url      = local.normalized_docker_image != "" && var.docker_registry != null && length(var.docker_registry) > 0 ? lookup(var.docker_registry, "url", null) : null
      docker_registry_username = local.normalized_docker_image != "" && var.docker_registry != null && length(var.docker_registry) > 0 ? lookup(var.docker_registry, "username", null) : null
      docker_registry_password = local.normalized_docker_image != "" && var.docker_registry != null && length(var.docker_registry) > 0 ? lookup(var.docker_registry, "password", null) : null

      node_version   = local.normalized_docker_image == "" && startswith(local.normalized_linux_fx, "node|") ? replace(local.normalized_linux_fx, "node|", "") : null
      dotnet_version = local.normalized_docker_image == "" && startswith(local.normalized_linux_fx, "dotnetcore|") ? replace(local.normalized_linux_fx, "dotnetcore|", "") : null
    }
  }

  app_settings = merge(
    var.app_settings,
    local.normalized_docker_image != "" && var.docker_registry != null && length(var.docker_registry) > 0 ? {
      "DOCKER_REGISTRY_SERVER_URL"      = lookup(var.docker_registry, "url", "")
      "DOCKER_REGISTRY_SERVER_USERNAME" = lookup(var.docker_registry, "username", "")
      "DOCKER_REGISTRY_SERVER_PASSWORD" = lookup(var.docker_registry, "password", "")
    } : {}
  )

  tags = var.tags
}

resource "azurerm_windows_web_app" "app" {
  count               = local.is_windows ? 1 : 0
  name                = local.app_name
  location            = var.location
  resource_group_name = var.create_resource_group ? azurerm_resource_group.rg[0].name : var.resource_group_name
  service_plan_id     = azurerm_service_plan.plan.id

  site_config {
    always_on = true

    application_stack {
      current_stack  = startswith(local.normalized_linux_fx, "dotnet|") || startswith(local.normalized_linux_fx, "dotnetcore|") ? "dotnet" : null
      dotnet_version = startswith(local.normalized_linux_fx, "dotnet|") || startswith(local.normalized_linux_fx, "dotnetcore|") ? local.windows_dotnet_version : null
    }
  }

  app_settings = var.app_settings
  tags         = var.tags
}
