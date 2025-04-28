# OpenTofu_Modules
Modules for OpenTofu





### Workspaces
- development: Playground
- staging: Staging environment
- production: Production environment

### State

To store and share the state file we are using a Blob storage

### Local usage with docker

```
# Start the container with a shell
docker-compose run --rm app bash

# and initialize the az configuration
init-az.sh

```

## Terraspace

This is a Terraspace project. It contains code to provision Cloud infrastructure built with [Terraform](https://www.terraform.io/) and the [Terraspace Framework](https://terraspace.cloud/).

#### Deploy 

To deploy all the infrastructure stacks:

    terraspace all up

To deploy individual stacks:

    terraspace up keyvault # where demo is app/stacks/keyvault

To deploy an individual stack with an instance number

    terraspace up k8s --instance 01

if you want to override specific vars within an instance number, create e.g.
./app/stacks/k8s/tfvars/02.tfvars

Merge precedence 
config/terraform/tfvars/base.tfvars -> app/stacks/k8s/tfvars/base.tfvars  -> app/stacks/k8s/tfvars/development.tfvars -> app/stacks/k8s/tfvars/02.tfvars


##### Legacy Terraform way

Terraform

```

# Terraform init (run with reconfiguration in case we have updated our local modules) 
terraform init -reconfigure 
    
# Terraform plugin upgrade: Hint: This updates dependent packages which may contain backward breaking changes - use with caution 
terraform init -reconfigure -upgrade

# Workspaces
terraform workspace list

# create a new workspace
terraform worspace new <name>

# select your workspace
terraform workspace select dev

# Terraform plan: use our bash alias tfp
# terraform plan ${TF_VAR_FILES} e.g terraform plan -var-file=terraform.tfvars -var-file=development.tfvars
tfp

# Terraform apply: use our bash alias tfa
# terraform apply ${TF_VAR_FILES} e.g terraform apply -var-file=terraform.tfvars -var-file=development.tfvars
tfa
```