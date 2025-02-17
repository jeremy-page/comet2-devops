resource "aws_security_group" "jenkins_sg" {
  for_each    = var.env
  name        = "${each.key}-eks-jenkins-sg"
  description = "Security group for mgmt worker jenkins"
  vpc_id      = each.value.vpc_id

  tags = {
    Name = "${each.key}-eks-jenkins-sg"
  }
}

# # Security Group for Non-Prod jenkins
# resource "aws_security_group" "non_prod_jenkins_sg" {
#   name        = "${each.key}-eks-jenkins-sg"
#   description = "Security group for non-prod worker jenkins"
#   vpc_id      = each.value.vpc_id

#   tags = {
#     Name = "${each.key}-eks-jenkins-sg"
#   }
# }

# #  Security Group for Prod jenkins
# resource "aws_security_group" "prod_jenkins_sg" {
#   name        = "prod-eks-jenkins-sg"
#   description = "Security group for prod worker jenkins"
#   vpc_id      = aws_vpc.comet_vpc["prod-vpc"].id

#   tags = {
#     Name = "prod-eks-jenkins-sg"
#   }
# }

resource "aws_security_group_rule" "jenkins_egress" {
  for_each          = var.env
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = aws_security_group.jenkins_sg[each.key].id
  cidr_blocks       = ["0.0.0.0/0"]
}


resource "aws_security_group_rule" "jenkins_to_eks_cluster_https" {
  for_each                 = var.env
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = data.aws_security_group.cluster_sg[each.key].id
  source_security_group_id = aws_security_group.jenkins_sg[each.key].id

}
