
# data "template_file" "userdata" {
#   template = "${file("${path.module}/templates/userdata.sh")}"
#   vars = {
#     consul_address = "${aws_instance.consul.private_ip}"
#   }
# }

resource "aws_instance" "ec2_instance" {
  for_each               = var.env
  ami                    = data.aws_ami.latest_amazon_linux.id
  instance_type          = var.instance_type
  key_name               = aws_key_pair.ec2_key[each.key].id
  vpc_security_group_ids = [aws_security_group.jenkins_sg[each.key].id]
  subnet_id              = each.value.private_subnet_ids[0]
  user_data              = <<-EOF
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

  tags = {
    Name = "jumphost-instance-${each.key}"
  }
}