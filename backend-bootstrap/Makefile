# Makefile for Backend Bootstrap

TF := terraform

.PHONY: help init plan apply destroy fmt validate

help:
	@echo "Backend Bootstrap Makefile targets:"
	@echo "  make init                     # terraform init"
	@echo "  make plan WORKSPACE=dev       # plan backend creation for environment"
	@echo "  make apply WORKSPACE=dev      # apply backend creation for environment"
	@echo "  make destroy WORKSPACE=dev    # destroy backend for environment"
	@echo "  make fmt                      # terraform fmt -recursive"
	@echo "  make validate                 # terraform validate"

init:
	$(TF) init

plan:
	@if [ -z "$(WORKSPACE)" ]; then echo "Provide WORKSPACE=name (e.g. make plan WORKSPACE=dev)"; exit 1; fi
	@mkdir -p plan
	$(TF) plan -var "environment=$(WORKSPACE)" -out="plan/$(WORKSPACE).tfplan"

apply:
	@if [ -z "$(WORKSPACE)" ]; then echo "Provide WORKSPACE=name (e.g. make apply WORKSPACE=dev)"; exit 1; fi
	@if [ ! -f "plan/$(WORKSPACE).tfplan" ]; then echo "Missing plan file: plan/$(WORKSPACE).tfplan"; exit 1; fi
	$(TF) apply "plan/$(WORKSPACE).tfplan"

destroy:
	@if [ -z "$(WORKSPACE)" ]; then echo "Provide WORKSPACE=name (e.g. make destroy WORKSPACE=dev)"; exit 1; fi
	$(TF) destroy -var "environment=$(WORKSPACE)"

fmt:
	$(TF) fmt -recursive

validate:
	$(TF) validate
