
output "private_subnet_ids" {
  value = { for vpc_name in keys(var.vpcs) : vpc_name => [
    for subnet in aws_subnet.comet_private_sn : subnet.id if startswith(subnet.tags["Name"], vpc_name)
  ] }
}


output "public_subnet_ids" {
  value = { for vpc_name in keys(var.vpcs) : vpc_name => [
    for subnet in aws_subnet.comet_public_sn : subnet.id if startswith(subnet.tags["Name"], vpc_name)
  ] }
}


output "mgmt_nodes_sg_id" {
  value = aws_security_group.mgmt_nodes_sg.id
}

output "non_prod_nodes_sg_id" {
  value = aws_security_group.non_prod_nodes_sg.id
}

output "prod_nodes_sg_id" {
  value = aws_security_group.prod_nodes_sg.id
}


output "vpc_ids" {
  description = "VPC IDs for each environment"
  value       = { for k, v in aws_vpc.comet_vpc : k => v.id }
}

