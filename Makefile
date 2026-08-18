# Makefile to manage Terraform workspace and commands

TF := terraform

.PHONY: help init workspace plan apply destroy fmt validate show-workspace

help:
	@echo "Makefile targets:"
	@echo "  make init                     # terraform init"
	@echo "  make workspace WORKSPACE=dev   # select or create workspace"
	@echo "  make show-workspace           # show current terraform workspace"
	@echo "  make plan [WORKSPACE=dev]     # run terraform plan (selects workspace if provided)"
	@echo "  make apply [WORKSPACE=dev]    # apply last plan (selects workspace if provided)"
	@echo "  make destroy [WORKSPACE=dev]  # terraform destroy (selects workspace if provided)"
	@echo "  make fmt                      # terraform fmt -recursive"
	@echo "  make validate                 # terraform validate"

init:
	$(TF) init

workspace:
	@if [ -z "$(WORKSPACE)" ]; then echo "Provide WORKSPACE=name (e.g. make workspace WORKSPACE=dev)"; exit 1; fi
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
	@echo "Using workspace: $$(terraform workspace show 2>/dev/null || echo default)"
	@PLAN_FILE="plan/$${WORKSPACE:-default}.tfplan"; echo "Saving plan to $$PLAN_FILE"; $(TF) plan -out="$$PLAN_FILE"

apply:
	@if [ -z "$(WORKSPACE)" ]; then WORKSPACE=$$(terraform workspace show 2>/dev/null || echo default); fi
	@if [ ! -z "$(WORKSPACE)" ]; then $(MAKE) workspace WORKSPACE=$(WORKSPACE); fi
	@PLAN_FILE="$${WORKSPACE:-default}.tfplan"; echo "Applying plan: $$PLAN_FILE"; $(TF) apply "$$PLAN_FILE"

destroy:
	@if [ ! -z "$(WORKSPACE)" ]; then $(MAKE) workspace WORKSPACE=$(WORKSPACE); fi
	$(TF) destroy

fmt:
	$(TF) fmt -recursive

validate:
	$(TF) validate
