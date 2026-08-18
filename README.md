# Azure Web App Terraform Workspace Setup

This workspace deploys Azure Linux Web Apps using Terraform workspaces. Resource names are automatically prefixed with the active workspace name, so a deployment in `dev` produces names like `dev-car`, `dev-car-rg`, and `dev-car-plan`.

## Workflow

The current [Makefile](Makefile) manages Terraform workspaces and plan files automatically.

### Create or select a workspace

```bash
make workspace WORKSPACE=dev
make workspace WORKSPACE=uat
make workspace WORKSPACE=prod
```

### Show the current workspace

```bash
make show-workspace
```

### Plan for a workspace

The plan file is named using the workspace name, for example `dev.tfplan`.
The Makefile automatically selects the matching environment tfvars file from the `env/` folder using the current workspace name.

```bash
make plan WORKSPACE=dev
make plan WORKSPACE=uat
make plan WORKSPACE=prod
```

This reads:

```text
env/dev.tfvars
env/uat.tfvars
env/prod.tfvars
```

and writes the plan to:

```bash
plan/dev.tfplan
plan/uat.tfplan
plan/prod.tfplan
```

### Apply a saved workspace plan

```bash
make apply WORKSPACE=dev
```

This applies the matching file:

```bash
plan/dev.tfplan
```

### Destroy the current workspace environment

```bash
make destroy WORKSPACE=dev
```

## Default deployment

The default project is a single Docker-based app named `car` using the image:

```hcl
docker_image = "htmldemo/car:latest"
```

With the `dev` workspace, the resulting Azure resource names are:

- App: `dev-car`
- Resource group: `dev-car-rg`
- App Service plan: `dev-car-plan`

## Project configuration

The root `projects` list is defined in [variables.tf](variables.tf). Each entry supports fields such as:

- `name`
- `location`
- `resource_group_name`
- `create_resource_group`
- `sku_tier`
- `sku_size`
- `linux_fx_version`
- `app_settings`
- `run_from_package`
- `docker_image`
- `docker_registry`

Example:

```hcl
{
  name         = "car"
  sku_tier     = "Standard"
  sku_size     = "S1"
  docker_image = "htmldemo/car:latest"
  app_settings = {
    "ENV" = "dev"
  }
  run_from_package = false
}
```

## Environment variable usage

You can also pass the projects array via `TF_VAR_projects`:

```bash
export TF_VAR_projects='[
  {"name":"car","docker_image":"htmldemo/car:latest","app_settings":{"ENV":"dev"}}
]'
```

The default region is controlled by `var.location` and defaults to `southeastasia`.

## Files of interest

- [terraform.tf](terraform.tf)
- [variables.tf](variables.tf)
- [main.tf](main.tf)
- [Makefile](Makefile)
- [modules/webapp/main.tf](modules/webapp/main.tf)
- [modules/webapp/variables.tf](modules/webapp/variables.tf)



## Production deployment checklist

Use this checklist before deploying to each environment.

### 1) Prepare environment config

Create or update the environment-specific variable files under the `env/` folder:

- `env/dev.tfvars`
- `env/uat.tfvars`
- `env/prod.tfvars`

Example:

```hcl
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
```

### 2) Prepare remote state backend

Use environment-specific backend config files:

```text
backend/
├── dev.hcl
├── uat.hcl
└── prod.hcl
```

Example backend config:

```hcl
resource_group_name  = "rg-terraform-state"
storage_account_name = "sttfstateprod001"
container_name       = "tfstate"
key                  = "azure-webapp-dev.tfstate"
```

### 3) Initialize and validate

```bash
terraform init -reconfigure -backend-config=backend/dev.hcl
terraform validate
terraform plan -var-file=env/dev.tfvars
```

For UAT and prod:

```bash
terraform init -reconfigure -backend-config=backend/uat.hcl
terraform plan -var-file=env/uat.tfvars

terraform init -reconfigure -backend-config=backend/prod.hcl
terraform plan -var-file=env/prod.tfvars
```

### 4) Deploy with workspace separation

```bash
make workspace WORKSPACE=dev
make plan WORKSPACE=dev
make apply WORKSPACE=dev
```

### 5) Post-deployment checks

- Confirm Azure resource group and app service names match the environment
- Confirm tags exist for `Environment`, `Owner`, `Application`, and `ManagedBy`
- Confirm Docker image is the intended version
- Confirm app settings and secrets are correct
- Verify state is stored in the remote backend, not local disk

## Terraform State File

For production-grade deployments, Terraform state should live in a remote Azure Storage backend instead of local files. This keeps state secure, shared, and protected from accidental corruption during concurrent runs.

A common structure is:

```text
Resource Group: rg-terraform-state
└── Storage Account: sttfstateprod001
    └── Container: tfstate
        ├── azure-webapp-dev.tfstate
        ├── azure-webapp-uat.tfstate
        └── azure-webapp-prod.tfstate
```

The backend is configured in the root Terraform definition:

```hcl
terraform {
  backend "azurerm" {}
}
```

The project Makefile includes the same workflow:

```bash
make init-backend ENV=dev
make init-backend ENV=uat
make init-backend ENV=prod
```

I would not store `terraform.tfstate` in Git. State can contain sensitive values, resource IDs, outputs, and configuration details. Remote state in Azure Blob Storage is the recommended pattern for collaborative and production-safe Terraform workflows.