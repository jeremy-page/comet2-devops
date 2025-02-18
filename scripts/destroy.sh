
## todo
# delete jenkins r53 record
# delete the jenkisn alb to disassoc the cert



#!/bin/bash

set -e  
set -x  


# Run Terraform commands
echo "Initializing Terraform..."
cd ../terraform
terraform init

echo "Applying Terraform configuration..."

#################### Jumphost Destroy ##########################
terraform destroy -target=module.jumphost -auto-approve

##################### Jenkins Destroy ##########################

# delete jenkins r53 record
HOSTED_ZONE_ID=$(aws route53 list-hosted-zones-by-name \
    --dns-name "black.icf-comet-cc.com" \
    --query "HostedZones[0].Id" \
    --output text --region us-east-1)


# Fetch the ALB ARN and DNS name for jenkins
ALB_INFO=$(aws elbv2 describe-load-balancers \
    --query "LoadBalancers[?starts_with(LoadBalancerName, 'k8s-jenkinsalb-')]" \
    --output json --region us-east-1)

# Extract ALB DNS name and Hosted Zone ID
ALB_DNS_NAME=$(echo "$ALB_INFO" | jq -r '.[0].DNSName')
ALB_ZONE_ID=$(echo "$ALB_INFO" | jq -r '.[0].CanonicalHostedZoneId')

if [[ -z "$ALB_DNS_NAME" || "$ALB_DNS_NAME" == "null" ]]; then
    echo "ERROR: No ALB found with the name k8s-jenkinsalb-*"
    exit 1
fi

echo "Found ALB DNS Name: $ALB_DNS_NAME"
echo "Found ALB Hosted Zone ID: $ALB_ZONE_ID"

# delete record
aws route53 change-resource-record-sets \
    --hosted-zone-id "$HOSTED_ZONE_ID" \
    --change-batch '{
        "Changes": [{
            "Action": "DELETE",
            "ResourceRecordSet": {
                "Name": "jenkins.black.icf-comet-cc.com.",
                "Type": "A",
                "AliasTarget": {
                    "HostedZoneId": "'"$ALB_ZONE_ID"'",
                    "DNSName": "'"$ALB_DNS_NAME"'",
                    "EvaluateTargetHealth": false
                }
            }
        }]
    }' >/dev/null 2>&1

if [ $? -ne 0 ]; then
    echo "Route 53 record deletion failed. Exiting..."
    exit 1
fi

echo "Route 53 record deleted successfully. Continuing..."


terraform destroy -target=module.jenkins -auto-approve



###################### EKS Destroy ##########################

terraform destroy -target=module.eks -auto-approve

###################### Network Destroy ##########################
# delete the sgs left behind by eks (k8s-sgs)

for sg_id in $(aws ec2 describe-security-groups --region us-east-1 --query "SecurityGroups[?starts_with(GroupName, 'k8s-')].GroupId" --output text); do
    echo "Deleting security group: $sg_id"
    aws ec2 delete-security-group --region us-east-1 --group-id "$sg_id"
done

terraform destroy -target=module.network -auto-approve