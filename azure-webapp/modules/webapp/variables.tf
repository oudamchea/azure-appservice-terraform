variable "project_name" {
  type        = string
  description = "Name of the app / webapp."

  validation {
    condition     = length(trimspace(var.project_name)) > 0
    error_message = "project_name cannot be empty."
  }
}

variable "location" {
  type        = string
  description = "Azure region for the resources."

  validation {
    condition     = length(trimspace(var.location)) > 0
    error_message = "location cannot be empty."
  }
}

variable "create_resource_group" {
  type    = bool
  default = true
}

variable "resource_group_name" {
  type        = string
  description = "Resource group name to use when not creating a dedicated RG."
  default     = ""
}

variable "sku_tier" {
  type        = string
  description = "Legacy compatibility value for App Service plan tier. Current Docker deployment uses sku_size only."
  default     = "Standard"
}

variable "sku_size" {
  type        = string
  description = "App Service plan SKU size, for example B1, S1, P1v3."
  default     = "B1"

  validation {
    condition     = length(trimspace(var.sku_size)) > 0
    error_message = "sku_size cannot be empty."
  }
}

variable "linux_fx_version" {
  type        = string
  description = "Optional runtime version for non-Docker deployments. Current project uses Docker images only."
  default     = ""
}

variable "app_settings" {
  type    = map(any)
  default = {}
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "run_from_package" {
  type        = bool
  description = "Legacy compatibility flag kept for package-based deployment workflows; currently not used for Docker image deployment."
  default     = false
}

variable "kind" {
  type        = string
  description = "Legacy compatibility field retained for future extensions; not used by the current Linux Web App configuration."
  default     = "Linux"
}

variable "reserved" {
  type        = bool
  description = "Legacy compatibility field retained for future use; not used by the current Linux Web App configuration."
  default     = true
}

# Optional: specify a docker image to run in the webapp.
# This is the active deployment pattern for the current project.
variable "docker_image" {
  type    = string
  default = ""

  validation {
    condition     = var.docker_image == "" || length(trimspace(var.docker_image)) > 0
    error_message = "docker_image, when set, cannot be empty."
  }
}

# Optional registry credentials (use secrets in a secure manner). Supported keys:
# "url", "username", "password".
variable "docker_registry" {
  type    = map(string)
  default = {}
}
