#### TERRAFORM
#List of infrastrucutre that gets created
 - 3 VPCs. mgmt, prod and non-prod
 - 12 Subnets (2 Pub, 2 Priv) for each VPC
 - IGW for each VPC
 - NAT for each VPC
 - VPC Endpoints
 - VPC Peering betwen Mgmt <-> Prod and Mgmt <-> non-Prod
 - 3 EKs clusters mgmt, prod and non-prod
 - 3 EKS Nodegroups
 - 3 Launchtemplates
 - 3 Node Groups SGs for each nodegroup 
 - SG rules

## How to Run
# if runninf with target paramter, modules should follow this order

- network
- eks
- jenkins
- jumphost

# Pre-req

1. create an AWS profile for the Comet account , if you have other profiles stored in your .aws/credentials
2. export AWS_PROFILE=comet-black-admin
3. Install AWS CLI - homebrew
4. Install Helm CLI - homebrew
5. Create an S3 bucket in your account to store the TF state file and update your provider.tf with that bucket name


# After
- update navy account with NS records for hosted zone



#### K8S

## Items to scripts (automate)

# EKS
- modify cluster via terraform to include pub subnets on cluster not LT or nodegroup

# Jenkins
- helm repo add jenkins https://charts.jenkins.io
- helm repo update
- Apply templates using kubectl
- helm install jenkins-release jenkins/jenkins -n jenkins -f ./jenkins/values.yaml
- get the jenkins password - kubectl get secret --namespace jenkins jenkins-release -o jsonpath="{.data.jenkins-admin-password}" | base64 --decode (exclude the % at the end)
- jenkins uses jenkins/inbound-agent docker image  for worker nodes, this image enables connectivity to the controller, so the custom image might need to use this as base image

# ALB Controller

- helm repo add eks https://aws.github.io/eks-charts
- add vpc-id, cluster name name and service account name to helm values
- tag pub subnets via terraform
    kubernetes.io/cluster/mgmt-comet-cluster - shared
    kubernetes.io/role/elb - 1
    
- helm install aws-load-balancer-controller eks/aws-load-balancer-controller --version 1.4.3 -f mgmt-values.yaml  -n jenkins

- upadate hosted zone records in navy account?? probably a coding challenge thing?


## Notes
# Helm charts
-  helm create jenkins

# Service Mesh ??
- best bet is istio

yGvtgMREbHH59URQ56WQMD
