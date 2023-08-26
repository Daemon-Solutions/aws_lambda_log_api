# http://clarkgrubb.com/makefile-style-guide

MAKEFLAGS += --warn-undefined-variables --no-print-directory
SHELL := bash
.SHELLFLAGS := -eu -o pipefail -c
.DEFAULT_GOAL := all
.DELETE_ON_ERROR:
.SUFFIXES:

REGION=eu-west-1
STACK=lambdaapi
TFSTATE_BUCKET=lambda-api-s3bucket-$(REGION)-tfstate
TF_LOCK_TABLE=lambda-api-s3bucket-$(REGION)-$(STACK)

export AWS_DEFAULT_REGION=$(REGION)

.PHONY: credsexpiring
credsexpiring:
	@if [ "$$(type -t awsexpires)" == "function" ]; then \
		if [ $$(awsexpires) -lt 10 ]; then \
			echo "AWS credentials are due to expire in: $$(awsexpires -h)"; \
			echo "Aborting to prevent failed TF run, please renew your credentials."; \
			exit 1; \
		fi; \
	fi

.PHONY: all
all: credsexpiring clean init fmt plan

.PHONY: apply
apply: credsexpiring tfapply

.PHONY: destroy
destroy: credsexpiring all tfdestroy

.PHONY: clean
clean:
	@rm -fr .terraform/modules
	@rm -fr .terraform/terraform.tfstate*
	@rm -fr .terraform/*zip

.PHONY: init
tinit:
	@rm -fr .terraform/
	@terraform init -backend=true -backend-config="bucket=$(TFSTATE_BUCKET)" -backend-config="key=$(STACK).tfstate" -backend-config="dynamodb_table=$(TF_LOCK_TABLE)" -get=true -upgrade

.PHONY: fmt
fmt:
	@terraform fmt

.PHONY: plan
tplan:
	@terraform plan -input=false -out=./plan.tfout

.PHONY: refresh
refresh: clean init fmt
	@terraform refresh

.PHONY: tfapply
tfapply:
	@terraform apply -input=false ./plan.tfout

.PHONY: tfsec
tfsec:
	@tfsec --tfvars-file params/params.tfvars


.PHONY: tfdestroy
tfdestroy:
	@terraform destroy

.PHONY: onetime
# Sets up
onetimes3:
	@aws s3api create-bucket \
		--region $(REGION) \
		--create-bucket-configuration LocationConstraint="$(REGION)" \
		--bucket $(TFSTATE_BUCKET)
	@aws s3api put-bucket-versioning \
		--region $(REGION) \
		--bucket $(TFSTATE_BUCKET) \
		--versioning-configuration Status=Enabled
	@aws s3api put-bucket-encryption \
            --bucket $(TFSTATE_BUCKET) \
            --server-side-encryption-configuration '{"Rules": [{"ApplyServerSideEncryptionByDefault": {"SSEAlgorithm": "AES256"}}]}'
onetimedynamodb:
	@aws dynamodb create-table \
		--region $(REGION) \
		--table-name $(TF_LOCK_TABLE) \
		--attribute-definitions AttributeName=LockID,AttributeType=S \
		--key-schema AttributeName=LockID,KeyType=HASH \
		--provisioned-throughput ReadCapacityUnits=1,WriteCapacityUnits=1
