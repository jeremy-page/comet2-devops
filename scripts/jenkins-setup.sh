# #!/bin/bash

# set -e  
# set -x  


# aws eks update-kubeconfig --region us-east-1 --name mgmt-comet-cluster

# helm repo add jenkins https://charts.jenkins.io
# helm repo add eks https://aws.github.io/eks-charts
# helm repo update

# kubectl apply -f ../k8s/namespaces/namespace.yaml

# # Fetch ACM cert ARN for the domain
# ACM_CERT_INFO=$(aws acm list-certificates \
#     --query "CertificateSummaryList[?DomainName=='black.icf-comet-cc.com']" \
#     --output json --region us-east-1)

# # Extract the ACM ARN
# ACM_CERT_ARN=$(echo "$ACM_CERT_INFO" | jq -r '.[0].CertificateArn')

# # Extract the main domain from ACM
# MAIN_DOMAIN=$(echo "$ACM_CERT_INFO" | jq -r '.[0].DomainName')

# # Construct Jenkins subdomain
# JENKINS_DOMAIN="jenkins.$MAIN_DOMAIN"

# if [[ -z "$ACM_CERT_ARN" || "$ACM_CERT_ARN" == "null" ]]; then
#     echo "ERROR: No ACM certificate found for $MAIN_DOMAIN"
#     exit 1
# fi

# echo "Found ACM Certificate ARN: $ACM_CERT_ARN"
# echo "Using Jenkins Subdomain: $JENKINS_DOMAIN"

# PUBLIC_SUBNET_IDS=$(aws ec2 describe-subnets \
#     --filters "Name=tag:Name,Values=mgmt-vpc-public-*" \
#     --query "Subnets[*].SubnetId" \
#     --output text --region us-east-1)

# # Convert space-separated output to comma-separated values
# PUBLIC_SUBNET_IDS=$(echo $PUBLIC_SUBNET_IDS | tr ' ' ',')

# # Check if any public subnets were found
# if [[ -z "$PUBLIC_SUBNET_IDS" ]]; then
#     echo "ERROR: No public subnets found with name mgmt-vpc-public-*"
#     exit 1
# fi

# echo "Found Public Subnets: $PUBLIC_SUBNET_IDS"

# sed -i.bak "s|alb.ingress.kubernetes.io/certificate-arn:.*|alb.ingress.kubernetes.io/certificate-arn: $ACM_CERT_ARN|" ../k8s/alb/ingress.yaml

# sed -i.bak "s|alb.ingress.kubernetes.io/subnets:.*|alb.ingress.kubernetes.io/subnets: $PUBLIC_SUBNET_IDS|" ../k8s/alb/ingress.yaml

# sed -i.bak "s|host:.*|host: $JENKINS_DOMAIN|" ../k8s/alb/ingress.yaml

# cat ../k8s/alb/ingress.yaml
# kubectl apply -f ../k8s/alb/ingress.yaml




# ### install jenkins helm chart

# kubectl apply -f ../k8s/jenkins/templates/



# if helm list -n jenkins | grep -q "jenkins-release"; then
#     echo "Helm release 'jenkins-release' already exists. Upgrading..."
#     helm upgrade jenkins-release jenkins/jenkins -n jenkins -f ../k8s/jenkins/values.yaml

# else
#     helm install jenkins-release jenkins/jenkins -n jenkins -f ../k8s/jenkins/values.yaml

# fi
# sleep 10
# kubectl get pods -n jenkins

# ### install alb controller

# MGMT_VPC_ID=$(aws ec2 describe-vpcs \
#     --filters "Name=tag:Name,Values=mgmt-vpc" \
#     --query "Vpcs[0].VpcId" \
#     --output text --region us-east-1)

# if [[ -z "$MGMT_VPC_ID" || "$MGMT_VPC_ID" == "None" ]]; then
#     echo "ERROR: No VPC found with the name mgmt-vpc"
#     exit 1
# fi

# echo "Found VPC ID: $MGMT_VPC_ID"

# # Replace VPC ID in the values.yaml file
# sed -i.bak "s|vpcId:.*|vpcId: $MGMT_VPC_ID|" ../k8s/alb/mgmt-values.yaml


# if helm list -n jenkins | grep -q "aws-load-balancer-controller"; then
#     echo "Helm release 'aws-load-balancer-controller' already exists. Upgrading..."
#     helm upgrade aws-load-balancer-controller eks/aws-load-balancer-controller --version 1.4.3 -f ../k8s/alb/mgmt-values.yaml  -n jenkins

# else
#     helm install aws-load-balancer-controller eks/aws-load-balancer-controller --version 1.4.3 -f ../k8s/alb/mgmt-values.yaml  -n jenkins

# fi
# sleep 20


# # Update R53 record

# # Fetch the ALB ARN and DNS name
# ALB_INFO=$(aws elbv2 describe-load-balancers \
#     --query "LoadBalancers[?starts_with(LoadBalancerName, 'k8s-jenkinsalb-')]" \
#     --output json --region us-east-1)

# # Extract ALB DNS name and Hosted Zone ID
# ALB_DNS_NAME=$(echo "$ALB_INFO" | jq -r '.[0].DNSName')
# ALB_ZONE_ID=$(echo "$ALB_INFO" | jq -r '.[0].CanonicalHostedZoneId')

# if [[ -z "$ALB_DNS_NAME" || "$ALB_DNS_NAME" == "null" ]]; then
#     echo "ERROR: No ALB found with the name k8s-jenkinsalb-*"
#     exit 1
# fi

# echo "Found ALB DNS Name: $ALB_DNS_NAME"
# echo "Found ALB Hosted Zone ID: $ALB_ZONE_ID"

# HOSTED_ZONE_ID=$(aws route53 list-hosted-zones-by-name \
#     --dns-name "black.icf-comet-cc.com" \
#     --query "HostedZones[0].Id" \
#     --output text --region us-east-1)


# if [[ -z "$HOSTED_ZONE_ID" || "$HOSTED_ZONE_ID" == "None" ]]; then
#     echo "ERROR: No Hosted Zone found for black.icf-comet-cc.com"
#     exit 1
# fi

# echo "Found Hosted Zone ID: $HOSTED_ZONE_ID"

# # Create Route 53 Alias A record pointing jenkins.black.icf-comet-cc.com to the ALB
# aws route53 change-resource-record-sets \
#     --hosted-zone-id "$HOSTED_ZONE_ID" \
#     --change-batch '{
#         "Changes": [{
#             "Action": "UPSERT",
#             "ResourceRecordSet": {
#                 "Name": "jenkins.black.icf-comet-cc.com.",
#                 "Type": "A",
#                 "AliasTarget": {
#                     "HostedZoneId": "'"$ALB_ZONE_ID"'",
#                     "DNSName": "'"$ALB_DNS_NAME"'",
#                     "EvaluateTargetHealth": false
#                 }
#             }
#         }]
#     }'

# echo "Alias A record created successfully for jenkins.black.icf-comet-cc.com -> $ALB_DNS_NAME"

# JENKINS_PASSWORD=$(kubectl get secret --namespace jenkins jenkins-release -o jsonpath="{.data.jenkins-admin-password}" | base64 --decode)

# echo "################################################################"
# echo "Jenkins Admin Password: $JENKINS_PASSWORD"
# echo "################################################################"

# open "http://jenkins.black.icf-comet-cc.com"


cd ../scripts
sh jenkins-pipeline.sh 