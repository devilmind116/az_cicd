#!/bin/bash

echo "Installing Azure CLI"
sudo chmod +x install_az_cli.sh
./install_az_cli.sh

echo "Azure CLI login"
az login

echo "Install terraform"
chmod +x install_terraform.sh
./install_terraform.sh

echo "Terraform Plan and Apply"
terraform init
terraform plan
terraform apply
