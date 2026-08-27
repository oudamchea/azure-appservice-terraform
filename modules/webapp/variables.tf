variable "project_name" {
  type        = string
  description = "Name of the app / webapp"
}

variable "location" {
  type        = string
  description = "Azure region for the resources"
}

variable "create_resource_group" {
  type    = bool
  default = true
}

variable "resource_group_name" {
  type        = string
  description = "Resource group name to use when not creating"
  default     = ""
}

variable "sku_tier" {
  type    = string
  default = "Standard"
}

variable "sku_size" {
  type    = string
  default = "S1"
}

variable "os_type" {
  type        = string
  description = "App Service operating system: Linux or Windows"
  default     = "Linux"

  validation {
    condition     = contains(["linux", "windows"], lower(var.os_type))
    error_message = "os_type must be Linux or Windows."
  }
}

variable "linux_fx_version" {
  type    = string
  default = ""
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
  type    = bool
  default = true
}

variable "kind" {
  type    = string
  default = "Linux"
}

variable "reserved" {
  type    = bool
  default = true
}

# Optional: specify a docker image to run in the webapp. When set, the module
# will set `linux_fx_version` to `DOCKER|<image>` so the app runs the container.
variable "docker_image" {
  type    = string
  default = ""
}

# Optional registry credentials (use secrets in a secure manner). Supported keys:
# "url", "username", "password".
variable "docker_registry" {
  type    = map(string)
  default = {}
}
