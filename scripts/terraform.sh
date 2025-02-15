#!/bin/bash

set -e  
set -x  


# Run Terraform commands
echo "Initializing Terraform..."
cd ../terraform
terraform init

echo "Applying Terraform configuration..."
terraform apply -target=module.network -auto-approve
# terraform apply -target=module.eks -auto-approve
# terraform apply -target=module.jenkins -auto-approve
# terraform apply -target=module.jumphost -auto-approve



# Wait for all Terraform resources to be fully created
# echo "Waiting for all Terraform resources to be available..."
# terraform state list | while read -r resource; do
#   terraform state show "$resource" > /dev/null 2>&1 || {
#     echo "Resource $resource not fully created yet. Retrying..."
#     sleep 5
#   }
# done

echo "Terraform deployment completed successfully!"
