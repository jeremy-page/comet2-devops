

JENKINS_PASSWORD=$(kubectl get secret --namespace jenkins jenkins-release -o jsonpath="{.data.jenkins-admin-password}" | base64 --decode)
cd ../jenkins-with-terraform
terraform init

terraform apply -var="jenkins_password=$JENKINS_PASSWORD" -auto-approve