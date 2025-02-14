variable "vpcs" {
  description = "Map of VPCs with their configurations"
  type = map(object({
    cidr_block           = string
    enable_dns_support   = bool
    enable_dns_hostnames = bool
    tags                 = map(string)
    public_subnets       = list(object({ cidr = string, az = string }))
    private_subnets      = list(object({ cidr = string, az = string }))
    needs_igw            = bool
    env  = string
  }))
}

variable "vpc_peering_connections" {
  description = "List of VPC peering connections"
  type = list(object({
    requester = string
    accepter  = string
  }))
  default = []
}

variable "aws_region" {
  
}

variable "availability_zones" {
  description = "List of availability zones to distribute subnets across"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b", "us-east-1c", "us-east-1d",] 
}