location = "southeastasia"

tags = {
  Environment = "dev"
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
      ENV = "dev"
    }
  }
]
