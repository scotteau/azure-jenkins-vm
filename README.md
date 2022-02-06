# Terraform script for a jenkins server on Azure

## How to use

### 1. Setup required folders
Run `scripts/setup.sh` first, to setup folders structure required.

### 2. Initialise terraform project
Run `terraform init` to init this terraform project

### 3. Tweak parameters or resources according to your need.

Change naming related stuff in `terraform.tfvars` file.

Adjust resources in `main.tf` file.

### 4. Run `terraform apply` to provision azure vm

### 5. Connect to your VM 
If things work well, you should have a copy of your ssh key with in `credential` folder and a `ssh.sh` script with in `scripts` folder.

Run `ssh.sh` to connect to your vm.

### 6. Destroy resources by running `terraform destroy`
