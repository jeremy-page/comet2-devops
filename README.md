
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

# Pre-req

1. create an AWS profile for the Comet account , if you have other profiles stored in your .aws/credentials
2. export AWS_PROFILE=comet-black-admin
3. Install AWS CLI - homebrew
4. Install Helm CLI - homebrew
5. Create an S3 bucket in your account to store the TF state file and update your provider.tf with that bucket name