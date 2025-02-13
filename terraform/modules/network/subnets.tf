resource "aws_subnet" "comet_public_sn" {
  for_each = { for subnet_data in flatten([
      for vpc_name, vpc_data in var.vpcs : [
        for index, subnet in vpc_data.public_subnets : {
          key        = "${vpc_name}-public-${index}"
          vpc_id     = aws_vpc.comet_vpc[vpc_name].id
          cidr_block = subnet.cidr
          az         = subnet.az
        }
      ]
    ]) : subnet_data.key => subnet_data
  }

  vpc_id                  = each.value.vpc_id
  cidr_block              = each.value.cidr_block
  availability_zone       = each.value.az
  map_public_ip_on_launch = true

  tags = {
    Name = each.key
  }
}


resource "aws_subnet" "comet_private_sn" {
  for_each = { for subnet_data in flatten([
      for vpc_name, vpc_data in var.vpcs : [
        for index, subnet in vpc_data.private_subnets : {
          key        = "${vpc_name}-private-${index}"
          vpc_id     = aws_vpc.comet_vpc[vpc_name].id
          cidr_block = subnet.cidr
          az         = subnet.az
        }
      ]
    ]) : subnet_data.key => subnet_data
  }

  vpc_id            = each.value.vpc_id
  cidr_block        = each.value.cidr_block
  availability_zone = each.value.az

  tags = {
    Name = each.key
  }
}


# vpc endpoints

variable "vpc_interface_endpoints" {
  type = list 
  default = ["ssmmessages", "ecr.api", "ecr.dkr", "ssm", "ec2messages"]
  
}

# Interface VPC Endpoints for Each Prod VPC
resource "aws_vpc_endpoint" "prod_interface" {
  for_each = toset(var.vpc_interface_endpoints)
  vpc_id             = aws_vpc.comet_vpc["prod-vpc"].id
  vpc_endpoint_type  = "Interface"
  service_name       = "com.amazonaws.${var.aws_region}.${each.value}"
  subnet_ids = [
    aws_subnet.comet_private_sn["prod-vpc-private-0"].id,
    aws_subnet.comet_private_sn["prod-vpc-private-1"].id
  ]

  security_group_ids = [aws_security_group.prod_nodes_sg.id]

  tags = {
    Name = "prod-${each.value}-vpc-endpoint"
  }
}
resource "aws_vpc_endpoint" "non_prod_interface" {
  for_each = toset(var.vpc_interface_endpoints)
  vpc_id             = aws_vpc.comet_vpc["non-prod-vpc"].id
  vpc_endpoint_type  = "Interface"
  service_name       = "com.amazonaws.${var.aws_region}.${each.value}"
  subnet_ids = [
    aws_subnet.comet_private_sn["non-prod-vpc-private-0"].id,
    aws_subnet.comet_private_sn["non-prod-vpc-private-1"].id
  ]

  security_group_ids = [aws_security_group.non_prod_nodes_sg.id]

  tags = {
    Name = "non-prod-${each.value}-vpc-endpoint"
  }
}

resource "aws_vpc_endpoint" "mgmt_interface" {
  for_each = toset(var.vpc_interface_endpoints)
  vpc_id             = aws_vpc.comet_vpc["mgmt-vpc"].id
  vpc_endpoint_type  = "Interface"
  service_name       = "com.amazonaws.${var.aws_region}.${each.value}"
  subnet_ids = [
    aws_subnet.comet_private_sn["mgmt-vpc-private-0"].id,
    aws_subnet.comet_private_sn["mgmt-vpc-private-1"].id
  ]

  security_group_ids = [aws_security_group.mgmt_nodes_sg.id]

  tags = {
    Name = "mgmt-${each.value}-vpc-endpoint"
  }
}
# Gateway VPC Endpoint for S3 for Each Prod VPC
resource "aws_vpc_endpoint" "prod_s3" {
  vpc_id             = aws_vpc.comet_vpc["prod-vpc"].id
  vpc_endpoint_type = "Gateway"
  service_name    = "com.amazonaws.${var.aws_region}.s3"
  route_table_ids = [
    aws_route_table.comet_private_rt["prod-vpc"].id
   
    ]

  tags = {
    Name = "prod-s3-vpc-endpoint"
  }
}
# Gateway VPC Endpoint for S3 for Each Non Prod VPC
resource "aws_vpc_endpoint" "non_prod_s3" {
  vpc_id             = aws_vpc.comet_vpc["non-prod-vpc"].id
  vpc_endpoint_type = "Gateway"
  service_name    = "com.amazonaws.${var.aws_region}.s3"
  route_table_ids = [
    aws_route_table.comet_private_rt["non-prod-vpc"].id
   
    ]

  tags = {
    Name = "non-prod-s3-vpc-endpoint"
  }
}
# Gateway VPC Endpoint for S3 for Each Mgmt VPC
resource "aws_vpc_endpoint" "mgmt_s3" {
  vpc_id             = aws_vpc.comet_vpc["mgmt-vpc"].id
  vpc_endpoint_type = "Gateway"
  service_name    = "com.amazonaws.${var.aws_region}.s3"
  route_table_ids = [
    aws_route_table.comet_private_rt["mgmt-vpc"].id
   
    ]

  tags = {
    Name = "mgmt-s3-vpc-endpoint"
  }
}

