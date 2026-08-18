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

```bash
make plan WORKSPACE=dev
```

This saves the plan to:

```bash
dev.tfplan
```

### Apply a saved workspace plan

```bash
make apply WORKSPACE=dev
```

This applies the matching file:

```bash
dev.tfplan
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



## Terrafrom State File

A common structure is:

Resource Group: rg-terraform-state
└── Storage Account: sttfstateprod001
    └── Container: tfstate
        ├── dev/azure-webapp.tfstate
        ├── uat/azure-webapp.tfstate
        └── prod/azure-webapp.tfstate

Then configure Terraform like this:

terraform {
  backend "azurerm" {
    resource_group_name  = "rg-terraform-state"
    storage_account_name = "sttfstateprod001"
    container_name       = "tfstate"
    key                  = "dev/azure-webapp.tfstate"
  }
}

Azure Blob Storage is a good fit because the state is remote, encrypted at rest, and Blob Storage supports locking to help prevent simultaneous Terraform runs from corrupting state. Microsoft specifically recommends remote Azure Storage for Terraform state on Azure.

For your setup with Terraform workspaces, I’d be careful about mixing workspace logic and hardcoded state paths. A cleaner production pattern is often to keep each environment’s state clearly isolated, for example:

tfstate/
├── azure-webapp-dev.tfstate
├── azure-webapp-uat.tfstate
└── azure-webapp-prod.tfstate

or separate backend config files:

backend/
├── dev.hcl
├── uat.hcl
└── prod.hcl

Example:

# backend/dev.hcl


resource_group_name  = "rg-terraform-state"
storage_account_name = "sttfstateprod001"
container_name       = "tfstate"
key                  = "azure-webapp/dev.tfstate"

Then initialize with:

terraform init -backend-config=backend/dev.hcl

and for UAT:

terraform init -reconfigure \
  -backend-config=backend/uat.hcl

I would not store terraform.tfstate in Git. State can contain sensitive values, resource IDs, outputs, and configuration details, so keeping it in the repository is a security and concurrency risk. Microsoft also recommends remote state specifically because local state is not ideal for collaborative workflows.