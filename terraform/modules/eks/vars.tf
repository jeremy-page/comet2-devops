variable "eks_clusters" {
  description = "Map of EKS clusters and configurations"
  type = map(object({
    eks_version            = string
    eks_private_subnets    = list(string)
    alb_public_subnets    = list(string)
    nodegroup_desired_size = number
    nodegroup_max_size     = number
    nodegroup_min_size     = number
    # eks_nodegroup_instance_size = string
    sg = list(string)
  }))
}

variable "eks_nodegroup_instance_size" {

}


