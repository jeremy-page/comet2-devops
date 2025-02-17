
data "aws_ami" "latest_amazon_linux" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["amazon"]
}

data "aws_security_group" "cluster_sg" {
  for_each = var.env # Example: { "mgmt" = "mgmt-sg", "prod" = "prod-sg" }
  name     = each.value.default_cluster_sg
}
