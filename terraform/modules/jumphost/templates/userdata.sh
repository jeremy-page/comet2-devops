 #!/bin/bash
              # Install kubectl
              curl -o kubectl https://amazon-eks.s3.us-west-2.amazonaws.com/1.21.2/2021-07-05/bin/linux/amd64/kubectl
              chmod +x ./kubectl
              mv ./kubectl /usr/local/bin

              # Install Helm
              curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

              # Update kubeconfig
              aws eks update-kubeconfig --region us-east-1 --name ${each.key}-comet-cluster
              EOF