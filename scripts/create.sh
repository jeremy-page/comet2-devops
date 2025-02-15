#!/bin/bash

set -e  
set -x  

# Checks

TERRAFORM_VERSION=$(terraform version -json | jq -r '.terraform_version')

# Compare Terraform versions
if "$TERRAFORM_VERSION" < 1.9.0 ; then
    echo "Upgrade Terraform version. You have $TERRAFORM_VERSION but need at least $REQUIRED_VERSION."
    exit 1
else
    echo "Terraform version $TERRAFORM_VERSION is up to date."
fi

run_command() {
    OUTPUT=$($1 2>&1) 
    STATUS=$?          

    if [ $STATUS -ne 0 ]; then
        echo "Error running '$1'. Please check if it is installed and configured correctly."
        echo "Output: $OUTPUT"
        exit 1
    else
        echo "$OUTPUT"
    fi
}

run_command "helm version --short"

run_command "kubectl version --client --output=json"

run_command "aws --version"


sh ./terraform.sh 