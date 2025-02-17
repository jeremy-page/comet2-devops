
terraform {
  required_providers {
    jenkins = {
      source = "taiidani/jenkins"
      version = "0.10.2"
    }
  }
    backend "s3" {
    bucket = "comet-terraform-state-us-east-1"
    key    = "jenkins-terraform/terraform.tfstate"
    region = "us-east-1"

  }
}



provider "jenkins" {
  server_url = "https://jenkins.black.icf-comet-cc.com" # Or use JENKINS_URL env var
  username   = "admin"            # Or use JENKINS_USERNAME env var
  password   = var.jenkins_password           # Or use JENKINS_PASSWORD env var
  ca_cert = ""                       # Or use JENKINS_CA_CERT env var
}

resource "jenkins_folder" "sample-folder" {
  name = "ebuka-sample-jenkisn-folder"
}

resource "jenkins_job" "sample-job" {
  name     = "ebuka-sample-jenkins-job"
  folder   = jenkins_folder.sample-folder.id
  template = templatefile("./job-script.xml", {
    description = "An example job created from Terraform"
  })
}


## TODO
# resource "null_resource" "trigger_jenkins_job" {
#   provisioner "local-exec" {
#     command = <<EOT
#       set -x

#       JENKINS_URL="https://jenkins.black.icf-comet-cc.com"
#       JENKINS_USER="admin"
#       JENKINS_TOKEN="yGvtgMREbHH59URQ56WQMD"
#       JOB_NAME="ebuka-jenkins-tf-job"

#       # Ensure jq is installed (without sudo)
#       if ! command -v jq &> /dev/null; then
#         echo "jq not found, installing..."
#         apt-get update && apt-get install -y jq || yum install -y jq || brew install jq
#       fi

#       # Get Jenkins Crumb
#       CRUMB_RESPONSE=$(curl -s -u "$JENKINS_USER:$JENKINS_TOKEN" "$JENKINS_URL/crumbIssuer/api/json")
#       CRUMB=$(echo "$CRUMB_RESPONSE" | jq -r '.crumb')
#       CRUMB_FIELD=$(echo "$CRUMB_RESPONSE" | jq -r '.crumbRequestField')

#       # Validate that CRUMB was retrieved
#       if [[ -z "$CRUMB" || "$CRUMB" == "null" ]]; then
#         echo "Failed to retrieve Jenkins Crumb! Exiting..."
#         exit 1
#       fi

#       # Trigger Jenkins Job with CSRF Protection
#       curl -X POST "$JENKINS_URL/job/$JOB_NAME/build" \
#            --user "$JENKINS_USER:$JENKINS_TOKEN" \
#            -H "$CRUMB_FIELD: $CRUMB"
#     EOT
#   }
# }

