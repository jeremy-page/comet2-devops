
# List of infrastrucutre that gets created
 - 3 VPCs. mgmt, prod and non-prod
 - 12 Subnets (2 Pub, 2 Priv for each VPC)
 - IGW for each VPC
 - NAT for each VPC
 - VPC Endpoints
 - VPC Peering betwen Mgmt <-> Prod and Mgmt <-> non-Prod
 - 3 EKS clusters mgmt, prod and non-prod
 - 3 EKS Nodegroups
 - 3 Launchtemplates
 - 3 Node Groups SGs for each nodegroup 
 - SG rules

## How to Run

### Pre-Requisites

MacOS:
1. Create an AWS profile for the Comet account , if you have other profiles stored in your .aws/credentials
2. Configure AWS profile:
~~~~
* export AWS_PROFILE=comet-black-admin
* export AWS_SECRET_ACCESS_KEY=<secret key>
* export AWS_SESSION_TOKEN=<session token>
* export AWS_REGION=us-east-1
~~~~
3. Install AWS CLI - homebrew

  brew install awscli
4. Install Helm CLI - homebrew

  brew install helm
5. Install Terraform and tfenv - homebrew

  brew install tfenv
  tfenv install latest
  tfenv use latest
6. Create an S3 bucket in your account to store the TF state file and update your provider.tf with that bucket name

  aws s3api create-bucket -acl private -bucket <bucket-name>
7. Change to the /terraform directory; terraform init; terraform plan
