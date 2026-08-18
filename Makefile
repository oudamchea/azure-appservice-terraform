# Makefile to manage Terraform workspace and commands

TF := terraform

.PHONY: help init init-backend workspace plan apply destroy fmt validate show-workspace

help:
	@echo "Makefile targets:"
	@echo "  make init                     # terraform init"
	@echo "  make init-backend ENV=dev     # terraform init with backend config"
	@echo "  make workspace WORKSPACE=dev   # select or create workspace"
	@echo "  make show-workspace           # show current terraform workspace"
	@echo "  make plan [WORKSPACE=dev]     # run terraform plan and save under plan/"
	@echo "  make apply [WORKSPACE=dev]    # apply saved plan from plan/"
	@echo "  make destroy [WORKSPACE=dev]  # terraform destroy (selects workspace if provided)"
	@echo "  make fmt                      # terraform fmt -recursive"
	@echo "  make validate                 # terraform validate"

init:
	$(TF) init

init-backend:
	@if [ -z "$(ENV)" ]; then echo "Provide ENV=name (e.g. make init-backend ENV=dev)"; exit 1; fi
	$(TF) init -reconfigure -backend-config=backend/$(ENV).hcl

workspace:
	@if [ -z "$(WORKSPACE)" ]; then echo "Provide WORKSPACE=name (e.g. make workspace WORKSPACE=dev)"; exit 1; fi
	@if [ ! -f "backend/$(WORKSPACE).hcl" ]; then echo "Missing backend config: backend/$(WORKSPACE).hcl"; exit 1; fi
	@$(TF) init -reconfigure -backend-config=backend/$(WORKSPACE).hcl
	@if $(TF) workspace list | grep -q "$(WORKSPACE)"; then \
		$(TF) workspace select $(WORKSPACE); \
	else \
		$(TF) workspace new $(WORKSPACE); \
	fi

show-workspace:
	@$(TF) workspace show

plan:
	@if [ -z "$(WORKSPACE)" ]; then WORKSPACE=$$(terraform workspace show 2>/dev/null || echo default); fi
	@if [ ! -z "$(WORKSPACE)" ]; then $(MAKE) workspace WORKSPACE=$(WORKSPACE); fi
	@CURRENT_WORKSPACE=$$(terraform workspace show 2>/dev/null || echo default); \
	TFVARS_FILE="env/$${CURRENT_WORKSPACE}.tfvars"; \
	if [ ! -f "$$TFVARS_FILE" ]; then echo "Missing tfvars file: $$TFVARS_FILE"; exit 1; fi; \
	echo "Using workspace: $$CURRENT_WORKSPACE"; \
	echo "Using tfvars: $$TFVARS_FILE"; \
	PLAN_FILE="plan/$${CURRENT_WORKSPACE}.tfplan"; mkdir -p plan; \
	$(TF) plan -var-file="$$TFVARS_FILE" -out="$$PLAN_FILE"

apply:
	@if [ -z "$(WORKSPACE)" ]; then WORKSPACE=$$(terraform workspace show 2>/dev/null || echo default); fi
	@if [ ! -z "$(WORKSPACE)" ]; then $(MAKE) workspace WORKSPACE=$(WORKSPACE); fi
	@CURRENT_WORKSPACE=$$(terraform workspace show 2>/dev/null || echo default); \
	PLAN_FILE="plan/$${CURRENT_WORKSPACE}.tfplan"; \
	if [ ! -f "$$PLAN_FILE" ]; then echo "Missing plan file: $$PLAN_FILE"; exit 1; fi; \
	echo "Applying plan: $$PLAN_FILE"; \
	$(TF) apply "$$PLAN_FILE"

destroy:
	@if [ ! -z "$(WORKSPACE)" ]; then $(MAKE) workspace WORKSPACE=$(WORKSPACE); fi
	$(TF) destroy

fmt:
	$(TF) fmt -recursive

validate:
	$(TF) validate
