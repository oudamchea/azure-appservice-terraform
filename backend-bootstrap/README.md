# Backend Bootstrap

This directory contains Terraform code to create the Azure backend infrastructure (Resource Group, Storage Account, Container) needed for storing Terraform state files.

## Quick Start

From the **backend-bootstrap directory**:

```bash
# Initialize
make init

# Create backend for all environments
make plan WORKSPACE=dev && make apply WORKSPACE=dev
make plan WORKSPACE=uat && make apply WORKSPACE=uat
make plan WORKSPACE=prod && make apply WORKSPACE=prod
```

## Makefile Targets

| Target | Description |
|--------|-------------|
| `make init` | Initialize Terraform |
| `make plan WORKSPACE=<env>` | Plan backend creation for an environment |
| `make apply WORKSPACE=<env>` | Apply backend creation for an environment |
| `make destroy WORKSPACE=<env>` | Destroy backend for an environment |
| `make fmt` | Format Terraform files |
| `make validate` | Validate Terraform configuration |

Replace `<env>` with `dev`, `uat`, or `prod`.

## Parent Directory Makefile

Note: Backend bootstrap is managed separately within its own directory. The parent Makefile does not include bootstrap targets.

## Manual Usage (Direct Terraform)

If you prefer to use Terraform directly:

```bash
# Initialize
terraform init

# Plan and apply for each environment
terraform plan -var "environment=dev" -out="dev.tfplan"
terraform apply "dev.tfplan"

terraform plan -var "environment=uat" -out="uat.tfplan"
terraform apply "uat.tfplan"

terraform plan -var "environment=prod" -out="prod.tfplan"
terraform apply "prod.tfplan"
```

## Output

After applying, the outputs will show the backend configuration:
- Resource Group name
- Storage Account name
- Container name
- Backend configuration values

These values are pre-configured in the `../backend/*.hcl` files.

## Cleanup

To destroy backend infrastructure:

```bash
# Using Makefile (recommended)
make destroy WORKSPACE=dev
make destroy WORKSPACE=uat
make destroy WORKSPACE=prod

# Or using Terraform directly
terraform destroy -var "environment=dev"
terraform destroy -var "environment=uat"
terraform destroy -var "environment=prod"
```

**⚠️ Warning:** Destroying the backend will delete the state files. Only do this if you want to remove all infrastructure.
