variable "projects" {
  description = "List of projects to deploy. Each item is an object with keys: name, location, resource_group_name, create_resource_group, sku_tier, sku_size, linux_fx_version, app_settings, run_from_package, docker_image, and docker_registry."
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
    # {
    #   name             = "example-app-1"
    #   sku_tier         = "Basic"
    #   sku_size         = "B1"
    #   linux_fx_version = "NODE|16-lts"
    #   app_settings = {
    #     "ENV" = "dev"
    #   }
    #   run_from_package = true
    # },
    # {
    #   name             = "example-app-2"
    #   sku_tier         = "Basic"
    #   sku_size         = "B1"
    #   linux_fx_version = "DOTNETCORE|7.0"
    #   app_settings = {
    #     "ENV" = "dev"
    #   }
    #   run_from_package = true
    # }
    {
      name             = "car"
      sku_tier         = "Basic"
      sku_size         = "B1"
      docker_image     = "htmldemo/car:latest"
      run_from_package = false
    },
    {
      name             = "yoga"
      sku_tier         = "Basic"
      sku_size         = "B1"
      docker_image     = "htmldemo/yoga:0.0.1"
      run_from_package = false
    }
  ]
}

variable "location" {
  description = "Default Azure region to deploy resources into. Use the Azure region code. Default: Singapore (southeastasia)."
  type        = string
  default     = "southeastasia"
}

variable "tags" {
  description = "Common tags applied to created resources"
  type        = map(string)
  default     = {}
}
