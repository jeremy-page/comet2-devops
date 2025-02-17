#!/bin/bash

set -e  
# set -x  

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

run_command "kubectl version --client "

run_command "aws --version"

## hosted Zone

HOSTED_ZONE_INFO=$(aws route53 list-hosted-zones \
    --query "HostedZones[?ends_with(Name, 'icf-comet-cc.com.')].[Id, Name]" \
    --output text)

if [[ -z "$HOSTED_ZONE_INFO" ]]; then
    echo "No hosted zone found ending with 'icf-comet-cc.com'."
    echo "ERROR: Please create a hosted zone for your account color:"
    echo "   Example: black.icf-comet-cc.com"
    exit 1
else
    echo "################################################################"
    echo "Hosted zone found:"
    echo "   Domain: $(echo "$HOSTED_ZONE_INFO" | awk '{print $2}')"
    echo "   Hosted Zone ID: $(echo "$HOSTED_ZONE_INFO" | awk '{print $1}')"
    echo "################################################################"
fi

sh ./terraform.sh 