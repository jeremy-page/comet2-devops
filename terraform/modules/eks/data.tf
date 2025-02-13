
data "aws_security_group" "eks_cluster_sg" {
    for_each = var.eks_clusters
  filter {
    name   = "tag:Name"
    values = ["eks-cluster-sg-${each.key}-comet-cluster-*"] # ex: eks-cluster-sg-non-prod-comet-cluster-2018317863
  }
}

