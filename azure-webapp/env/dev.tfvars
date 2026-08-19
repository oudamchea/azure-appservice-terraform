location = "southeastasia"

projects = [
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

tags = {
  Environment = "dev"
  Owner       = "platform-team"
  Application = "azure-webapp"
  ManagedBy   = "terraform"
  CostCenter  = "IT-001"
}
