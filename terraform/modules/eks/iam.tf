resource "aws_iam_role" "eks_cluster_role" {
  for_each = var.eks_clusters
  name = "comet-${each.key}-eks-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "eks.amazonaws.com"
        }
      },
    ]
  })
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy",
    "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  ]
}
data "aws_iam_policy_document" "eks_nodes_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }

}


resource "aws_iam_role" "eks_node_role" {
    for_each = var.eks_clusters
  name               = "comet-${each.key}-eks-nodegroup-role"
  assume_role_policy = data.aws_iam_policy_document.eks_nodes_assume_role.json
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
    "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy",
    "arn:aws:iam::aws:policy/ElasticLoadBalancingFullAccess",
    "arn:aws:iam::aws:policy/CloudWatchFullAccess",
    "arn:aws:iam::aws:policy/AmazonS3FullAccess",
    "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
    
  ]
}

resource "aws_iam_instance_profile" "eks_node_instance_profile" {
    for_each = var.eks_clusters
  name = "comet-${each.key}-eks-nodegroup-instance-profile"
  role = aws_iam_role.eks_node_role[each.key].name
}