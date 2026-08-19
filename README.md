# Azure App Service Terraform Project

This project is organized into two main directories, each with independent Terraform configurations.

## Project Structure

```
.
├── backend-bootstrap/      # Infrastructure for Terraform state storage
│   ├── main.tf            # Storage account, container, resource group
│   ├── variables.tf       # Environment variable configuration
│   ├── outputs.tf         # Output values for backend configuration
│   ├── terraform.tf       # Provider and version requirements
│   ├── Makefile           # Workflow automation for backend bootstrap
│   └── README.md          # Backend bootstrap documentation
│
└── azure-webapp/          # Azure App Service infrastructure
    ├── backend/           # Backend configuration (.hcl files)
    ├── env/               # Environment-specific variables (.tfvars)
    ├── modules/           # Reusable Terraform modules
    ├── plan/              # Terraform plan files
    ├── terraform.tfstate.d/ # Local state files
    ├── main.tf            # Main resource definitions
    ├── variables.tf       # Input variables
    ├── outputs.tf         # Output values
    ├── terraform.tf       # Provider and version requirements
    ├── Makefile           # Workflow automation
    └── README.md          # Azure webapp documentation
```

## Quick Start

### 1. Set Up Backend Infrastructure

```bash
cd backend-bootstrap

# Initialize Terraform
make init

# Create backend for all environments
make plan WORKSPACE=dev && make apply WORKSPACE=dev
make plan WORKSPACE=uat && make apply WORKSPACE=uat
make plan WORKSPACE=prod && make apply WORKSPACE=prod
```

This creates the Azure storage accounts that will store your Terraform state files.

### 2. Set Up Azure Webapp Infrastructure

```bash
cd azure-webapp

# Initialize with backend configuration
make init-backend ENV=dev

# Create or select workspace
make workspace WORKSPACE=dev

# Plan and apply infrastructure
make plan WORKSPACE=dev && make apply WORKSPACE=dev
```

Repeat for `uat` and `prod` environments.

## Directory Details

### backend-bootstrap/

Manages the Terraform remote state storage infrastructure:
- Creates Azure Resource Group for state storage
- Creates Azure Storage Accounts (one per environment)
- Creates Storage Containers for state files
- Location: Singapore (southeastasia)

**Storage Account Names:**
- `oudamtfstatedev001` - Development state storage
- `oudamtfstateuat001` - UAT state storage
- `oudamtfstateprod001` - Production state storage

See [backend-bootstrap/README.md](backend-bootstrap/README.md) for detailed usage.

### azure-webapp/

Manages the Azure App Service infrastructure:
- Defines webapp resources and configurations
- Separates configurations by environment (dev, uat, prod)
- Uses remote state stored in the backend-bootstrap storage accounts

See [azure-webapp/README.md](azure-webapp/README.md) for detailed usage.

## Workflow

1. **Initialize Backend** - Create state storage infrastructure
2. **Initialize Webapp** - Configure Terraform to use the remote backend
3. **Plan & Apply** - Deploy the actual infrastructure

## Cleanup

### Remove Webapp Infrastructure
```bash
cd azure-webapp
make destroy WORKSPACE=prod  # Repeat for each environment
```

### Remove Backend Infrastructure
```bash
cd backend-bootstrap
make destroy WORKSPACE=prod  # Repeat for each environment
```

**⚠️ Warning:** Destroying backend will delete state files. Only do this if you want to completely remove all infrastructure.

## Support

- Each directory has its own Makefile with targets for `init`, `plan`, `apply`, `destroy`, `fmt`, and `validate`
- Run `make help` in any directory to see all available targets
- See individual README.md files for more details
