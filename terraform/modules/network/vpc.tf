resource "aws_vpc" "comet_vpc" {
  for_each             = var.vpcs
  cidr_block           = each.value.cidr_block
  enable_dns_support   = each.value.enable_dns_support
  enable_dns_hostnames = each.value.enable_dns_hostnames

  tags = merge(each.value.tags, { ManagedBy = "Terraform", })
}

resource "aws_internet_gateway" "comet_tgw" {
  depends_on = [aws_vpc.comet_vpc]
  for_each   = { for k, v in var.vpcs : k => v if v.needs_igw }

  vpc_id = aws_vpc.comet_vpc[each.key].id

  tags = {
    Name = "${each.key}-igw"
  }
}



resource "aws_vpc_peering_connection" "comet_vpc_peering" {
  depends_on = [aws_vpc.comet_vpc]
  for_each   = { for conn in var.vpc_peering_connections : "${conn.requester}-${conn.accepter}" => conn }

  vpc_id      = aws_vpc.comet_vpc[each.value.requester].id
  peer_vpc_id = aws_vpc.comet_vpc[each.value.accepter].id
  auto_accept = true

  tags = {
    Name = "peering-${each.value.requester}-${each.value.accepter}"
  }
}


resource "aws_route" "peering_routes" {
  depends_on = [aws_vpc.comet_vpc]
  for_each   = { for conn in var.vpc_peering_connections : "${conn.requester}-${conn.accepter}" => conn }

  route_table_id            = aws_vpc.comet_vpc[each.value.requester].main_route_table_id
  destination_cidr_block    = aws_vpc.comet_vpc[each.value.accepter].cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.comet_vpc_peering[each.key].id
}

resource "aws_route" "peering_routes_reverse" {
  depends_on = [aws_vpc.comet_vpc]
  for_each   = { for conn in var.vpc_peering_connections : "${conn.requester}-${conn.accepter}" => conn }

  route_table_id            = aws_vpc.comet_vpc[each.value.accepter].main_route_table_id
  destination_cidr_block    = aws_vpc.comet_vpc[each.value.requester].cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.comet_vpc_peering[each.key].id
}


# Allocate Elastic IP for each NAT Gateway
resource "aws_eip" "comet_nat_eip" {
  for_each = var.vpcs

  domain = "vpc"

  tags = {
    Name = "${each.key}-nat-eip"
  }
}

# Create NAT Gateway in the First Available Public Subnet
resource "aws_nat_gateway" "comet_nat_gw" {
  for_each = var.vpcs

  allocation_id = aws_eip.comet_nat_eip[each.key].id
  subnet_id     = sort([for subnet in aws_subnet.comet_public_sn : subnet.id if subnet.vpc_id == aws_vpc.comet_vpc[each.key].id])[0]

  tags = {
    Name = "${each.key}-nat-gw"
  }

  depends_on = [aws_internet_gateway.comet_tgw]
}


