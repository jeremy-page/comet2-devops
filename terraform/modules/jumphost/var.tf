variable "env" {
  description = "Map of commet env"
  type = map(object({
    example            = string
    vpc_id             = string
    default_cluster_sg = string
    private_subnet_ids = list(string)

  }))

}

# variable "vpc_id" {
#   description = "VPC ID"
#   type        = string
# }

# variable "ami_id" {
#   description = "AMI ID for the EC2 instances"
#   type        = string
# }

variable "instance_type" {
  description = "Instance type for the EC2 instances"
  type        = string
  default     = "t2.micro"
}