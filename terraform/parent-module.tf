module "network" {
  source = "./modules/network"

  vpcs = {
    mgmt-vpc = {
      cidr_block           = "10.0.0.0/16"
      enable_dns_support   = true
      enable_dns_hostnames = true
      tags                 = { Name = "mgmt-vpc" }
      public_subnets       = [{ cidr = "10.0.1.0/24", az = "us-east-1a" }, { cidr = "10.0.2.0/24", az = "us-east-1b" }]
      private_subnets      = [{ cidr = "10.0.3.0/24", az = "us-east-1a" }, { cidr = "10.0.4.0/24", az = "us-east-1b" }]
      needs_igw            = true
      env                  = "mgmt"
    }
    prod-vpc = {
      cidr_block           = "10.1.0.0/16"
      enable_dns_support   = true
      enable_dns_hostnames = true
      tags                 = { Name = "prod-vpc" }
      public_subnets       = [{ cidr = "10.1.1.0/24", az = "us-east-1a" }, { cidr = "10.1.2.0/24", az = "us-east-1b" }]
      private_subnets      = [{ cidr = "10.1.3.0/24", az = "us-east-1a" }, { cidr = "10.1.4.0/24", az = "us-east-1b" }]
      needs_igw            = true
      env                  = "prod"
    }
    non-prod-vpc = {
      cidr_block           = "10.2.0.0/16"
      enable_dns_support   = true
      enable_dns_hostnames = true
      tags                 = { Name = "non-prod-vpc" }
      public_subnets       = [{ cidr = "10.2.1.0/24", az = "us-east-1a" }, { cidr = "10.2.2.0/24", az = "us-east-1b" }]
      private_subnets      = [{ cidr = "10.2.3.0/24", az = "us-east-1a" }, { cidr = "10.2.4.0/24", az = "us-east-1b" }]
      needs_igw            = true
      env                  = "non-prod"
    }
  }
  vpc_peering_connections = [
    { requester = "mgmt-vpc", accepter = "prod-vpc" },
    { requester = "mgmt-vpc", accepter = "non-prod-vpc" }
  ]
  aws_region = "us-east-1"
}

module "eks" {
  depends_on = [module.network]
  source     = "./modules/eks"

  eks_clusters = {
    mgmt = {
      eks_version            = "1.30"
      eks_private_subnets    = flatten(module.network.private_subnet_ids["mgmt-vpc"])
      alb_public_subnets     = flatten(module.network.public_subnet_ids["mgmt-vpc"])
      nodegroup_desired_size = 2
      nodegroup_max_size     = 2
      nodegroup_min_size     = 2
      sg                     = [module.network.mgmt_nodes_sg_id]

    }
    prod = {
      eks_version         = "1.30"
      eks_private_subnets = flatten(module.network.private_subnet_ids["prod-vpc"])
      alb_public_subnets  = flatten(module.network.public_subnet_ids["prod-vpc"])
      # eks_public_subnets    = flatten(module.network.public_subnet_ids["prod-vpc"])
      nodegroup_desired_size = 2
      nodegroup_max_size     = 2
      nodegroup_min_size     = 2
      sg                     = [module.network.prod_nodes_sg_id]
    }
    non-prod = {
      eks_version            = "1.30"
      eks_private_subnets    = flatten(module.network.private_subnet_ids["non-prod-vpc"])
      alb_public_subnets     = flatten(module.network.public_subnet_ids["non-prod-vpc"])
      nodegroup_desired_size = 2
      nodegroup_max_size     = 2
      nodegroup_min_size     = 2
      sg                     = [module.network.non_prod_nodes_sg_id]
    }
  }
  eks_nodegroup_instance_size = "t3.large"
}


module "jenkins" {

  source              = "./modules/jenkins"
  zone_name           = "black.icf-comet-cc.com"
  acm_cert_domain     = "black.icf-comet-cc.com"
  acm_cert_alt_domain = ["*.black.icf-comet-cc.com"]

}

module "jumphost" {
  source = "./modules/jumphost"

  env = {
    mgmt = {
      example            = "example"
      vpc_id             = module.network.vpc_ids["mgmt-vpc"]
      default_cluster_sg = "eks-cluster-sg-mgmt-comet-cluster-*"
      private_subnet_ids = flatten(module.network.private_subnet_ids["mgmt-vpc"])
    }
    prod = {
      example            = "example"
      vpc_id             = module.network.vpc_ids["prod-vpc"]
      default_cluster_sg = "eks-cluster-sg-prod-comet-cluster-*"
      private_subnet_ids = flatten(module.network.private_subnet_ids["prod-vpc"])

    }
    non-prod = {
      example            = "example"
      vpc_id             = module.network.vpc_ids["non-prod-vpc"]
      default_cluster_sg = "eks-cluster-sg-non-prod-comet-cluster-*"
      private_subnet_ids = flatten(module.network.private_subnet_ids["non-prod-vpc"])
    }
  }
}