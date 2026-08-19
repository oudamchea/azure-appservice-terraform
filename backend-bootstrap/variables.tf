variable "environment" {
  description = "Environment name (dev, uat, prod)"
  type        = string
  validation {
    condition     = contains(["dev", "uat", "prod"], var.environment)
    error_message = "Environment must be dev, uat, or prod."
  }
}

variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "southeastasia"
}

variable "resource_group_name" {
  description = "Name of the resource group for backend state"
  type        = string
  default     = "rg-terraform-state"
}

variable "storage_account_sku" {
  description = "Storage account SKU"
  type        = string
  default     = "Standard_LRS"
}

variable "container_name" {
  description = "Name of the storage container"
  type        = string
  default     = "tfstate"
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default = {
    managed_by = "terraform"
    purpose    = "backend-state"
  }
}
