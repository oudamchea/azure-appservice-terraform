location = "southeastasia"

projects = [
  {
    name         = "car"
    sku_tier     = "Standard"
    sku_size     = "B1"
    docker_image = "htmldemo/car:latest"
  },
  {
    name         = "yoga"
    sku_tier     = "Standard"
    sku_size     = "B1"
    docker_image = "htmldemo/yoga:0.0.1"
  }
]

tags = {
  Environment = "uat"
  Owner       = "platform-team"
  Application = "azure-webapp"
  ManagedBy   = "terraform"
  CostCenter  = "IT-001"
}

projects = [
  {
    name         = "car"
    sku_tier     = "Basic"
    sku_size     = "B1"
    docker_image = "htmldemo/car:latest"
    app_settings = {
      ENV = "uat"
    }
  }
]
