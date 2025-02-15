
resource "aws_eks_cluster" "comet_cluster" {
  for_each = var.eks_clusters

  name     = "${each.key}-comet-cluster"
  role_arn = aws_iam_role.eks_cluster_role[each.key].arn
  version  = each.value.eks_version

  access_config {
    authentication_mode                         = "API_AND_CONFIG_MAP"
    bootstrap_cluster_creator_admin_permissions = true
  }

  vpc_config {
    endpoint_public_access  = true
    endpoint_private_access = true
    subnet_ids              = concat(each.value.eks_private_subnets, each.value.alb_public_subnets)

    security_group_ids = each.value.sg
  }

  depends_on = [aws_iam_role.eks_cluster_role]
}

resource "aws_eks_node_group" "comet_nodegroup" {
  depends_on = [aws_launch_template.eks_nodegroup_lt]
  for_each   = var.eks_clusters

  cluster_name    = aws_eks_cluster.comet_cluster[each.key].name
  node_group_name = "${each.key}-comet-nodegroup"
  node_role_arn   = aws_iam_role.eks_node_role[each.key].arn
  subnet_ids      = each.value.eks_private_subnets

  ami_type = "AL2_x86_64"
  version  = aws_eks_cluster.comet_cluster[each.key].version

  capacity_type = "ON_DEMAND"

  scaling_config {
    desired_size = each.value.nodegroup_desired_size
    max_size     = each.value.nodegroup_max_size
    min_size     = each.value.nodegroup_min_size
  }

  update_config {
    max_unavailable = 1
  }

  launch_template {
    name    = aws_launch_template.eks_nodegroup_lt[each.key].name
    version = aws_launch_template.eks_nodegroup_lt[each.key].latest_version
  }
}
