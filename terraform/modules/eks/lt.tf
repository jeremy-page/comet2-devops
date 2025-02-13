

resource "aws_launch_template" "eks_nodegroup_lt" {
    for_each = var.eks_clusters
  depends_on = [aws_eks_cluster.comet_cluster]
  name       = "comet-${each.key}-eks-lt"
  # ebs_optimized = true
  # image_id = data.aws_ami.eks_nodegroup_ami.id # dont use image id when supplying ami type in node group resource
  instance_type = var.eks_nodegroup_instance_size

   block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size = 250
    }
  }
#   network_interfaces {
#     associate_public_ip_address = false
#     # security_groups = [ each.value.sg, data.aws_security_group.eks_cluster_sg[each.key].id ]
#   }
  vpc_security_group_ids = flatten([each.value.sg, data.aws_security_group.eks_cluster_sg[each.key].id])
  lifecycle {
    create_before_destroy = true
  }
#   key_name = "${var.env}_ec2_keypair"
  # user_data = filebase64("${path.module}/templates/userdata.sh")
#   tags = var.tags

  tag_specifications {
    resource_type = "instance"

    tags = merge(
      {
        Name = "eks-${each.key}-comet-worker-node"
      }

    #   var.tags

    )
  }

}