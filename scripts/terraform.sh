#!/bin/bash

set -e  
set -x  


# Run Terraform commands
echo "Initializing Terraform..."
cd ../terraform
terraform init

echo "Applying Terraform configuration..."
terraform apply -target=module.network -auto-approve
terraform apply -target=module.eks -auto-approve
terraform apply -target=module.jenkins -auto-approve
terraform apply -target=module.jumphost -auto-approve


echo "Terraform deployment completed successfully!"

echo "Proceeding to setup Jenkins......."
cd ../scripts
sh jenkins-setup.sh 
