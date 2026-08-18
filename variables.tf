variable "projects" {
  description = "List of deployment projects. Current deployment model is Docker-based, but legacy package fields remain for compatibility."
  type = list(object({
    name                  = string
    location              = optional(string)
    resource_group_name   = optional(string)
    create_resource_group = optional(bool)
    sku_tier              = optional(string)
    sku_size              = optional(string)
    linux_fx_version      = optional(string)
    app_settings          = optional(map(string))
    run_from_package      = optional(bool)
    docker_image          = optional(string)
    docker_registry       = optional(map(string))
  }))
  default = [
    {
      name         = "car"
      sku_tier     = "Basic"
      sku_size     = "B1"
      docker_image = "htmldemo/car:latest"
    },
    {
      name         = "yoga"
      sku_tier     = "Basic"
      sku_size     = "B1"
      docker_image = "htmldemo/yoga:0.0.1"
    }
  ]

  validation {
    condition     = length(var.projects) > 0
    error_message = "At least one project must be defined."
  }

  validation {
    condition     = length(distinct([for project in var.projects : lower(trimspace(project.name))])) == length(var.projects)
    error_message = "Project names must be unique."
  }

  validation {
    condition = alltrue([
      for project in var.projects :
      length(trimspace(project.name)) > 0 && (
        length(trimspace(try(project.docker_image, ""))) > 0 ||
        length(trimspace(try(project.linux_fx_version, ""))) > 0
      )
    ])
    error_message = "Each project must include a non-empty name and either a docker_image or linux_fx_version value."
  }
}

variable "location" {
  description = "Default Azure region for all resources."
  type        = string
  default     = "southeastasia"

  validation {
    condition     = length(trimspace(var.location)) > 0
    error_message = "The Azure region cannot be empty."
  }
}

variable "tags" {
  description = "Production-level tag policy applied to created resources. Required keys: Environment, Owner, Application, ManagedBy."
  type        = map(string)
  default     = {}

  validation {
    condition = alltrue([
      for key in ["Environment", "Owner", "Application", "ManagedBy"] :
      contains(keys(var.tags), key) && length(trimspace(try(var.tags[key], ""))) > 0
    ])
    error_message = "Tags must include non-empty values for Environment, Owner, Application, and ManagedBy."
  }

  validation {
    condition = alltrue([
      for key, value in var.tags :
      length(trimspace(key)) > 0 && length(trimspace(value)) > 0
    ])
    error_message = "Tag keys and values must be non-empty strings."
  }

  validation {
    condition     = contains(["dev", "uat", "prod"], lower(trimspace(try(var.tags["Environment"], ""))))
    error_message = "The Environment tag must be one of: dev, uat, prod."
  }
}
