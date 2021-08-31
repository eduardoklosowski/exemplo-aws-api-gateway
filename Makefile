.phony: init plan apply destroy fmt validate clean


init:
	terraform init -input=false

plan:
	terraform plan -input=false -var-file=config.tfvars

apply:
	terraform apply -input=false -var-file=config.tfvars -auto-approve

destroy:
	terraform destroy -input=false -var-file=config.tfvars

fmt:
	terraform fmt -check -diff -recursive

validate:
	terraform validate

clean:
	rm -rf .terraform outputs
