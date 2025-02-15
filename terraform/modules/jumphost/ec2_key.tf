resource "aws_key_pair" "ec2_key" {
  for_each   = var.env
  key_name   = "ec2-jumphost-key-${each.key}"
  public_key = tls_private_key.ec2_key[each.key].public_key_openssh
}

resource "tls_private_key" "ec2_key" {
  for_each  = var.env
  algorithm = "RSA"
  rsa_bits  = 2048
}

# resource "aws_secretsmanager_secret" "ec2_key_secret" {
#   count = length(var.eks_clusters)
#   name = "ec2-jumphost-key-${var.eks_clusters[count.index]}"
# }

# resource "aws_secretsmanager_secret_version" "ec2_key_secret_version" {
#   count = length(var.eks_clusters)
#   secret_id     = aws_secretsmanager_secret.ec2_key_secret[count.index].id
#   secret_string = tls_private_key.ec2_key[count.index].private_key_pem
# }

resource "aws_ssm_parameter" "ec2_key_param" {
  for_each = var.env
  name     = "ec2-jumphost-key-${each.key}"
  type     = "SecureString"
  value    = tls_private_key.ec2_key[each.key].private_key_pem
}