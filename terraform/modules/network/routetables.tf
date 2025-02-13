# Create Public Route Table (Routes to IGW)
resource "aws_route_table" "comet_public_rt" {
  for_each = { for k, v in var.vpcs : k => v if v.needs_igw }

  vpc_id = aws_vpc.comet_vpc[each.key].id

  tags = {
    Name = "${each.key}-public-route-table"
  }
}

# Create Private Route Table (Routes to NAT GW)
resource "aws_route_table" "comet_private_rt" {
  for_each = var.vpcs

  vpc_id = aws_vpc.comet_vpc[each.key].id

  tags = {
    Name = "${each.key}-private-route-table"
  }
}


#  Add Default Route (0.0.0.0/0) to IGW in Public Route Table
resource "aws_route" "public_rt_default_route" {
  for_each = aws_route_table.comet_public_rt

  route_table_id         = each.value.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.comet_tgw[each.key].id
}


# Add Default Route (0.0.0.0/0) to NAT Gateway in Private Route Table
resource "aws_route" "private_rt_default_route" {
  for_each = aws_route_table.comet_private_rt

  route_table_id         = each.value.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.comet_nat_gw[each.key].id
}


# Attach all Public Subnets to their respective Public Route Table
resource "aws_route_table_association" "comet_public_rt_assoc" {
  for_each = aws_subnet.comet_public_sn

  subnet_id      = each.value.id
  route_table_id = aws_route_table.comet_public_rt[split("-public", each.key)[0]].id
}

# Attach all Private Subnets to their respective Private Route Table
resource "aws_route_table_association" "comet_private_rt_assoc" {
  for_each = aws_subnet.comet_private_sn

  subnet_id      = each.value.id
  route_table_id = aws_route_table.comet_private_rt[split("-private", each.key)[0]].id
}




