# Security Group for MGMT Nodes
resource "aws_security_group" "mgmt_nodes_sg" {
  name        = "mgmt-eks-nodes-sg"
  description = "Security group for mgmt worker nodes"
  vpc_id      = aws_vpc.comet_vpc["mgmt-vpc"].id

  tags = {
    Name = "mgmt-eks-nodes-sg"
  }
}

# Security Group for Non-Prod Nodes
resource "aws_security_group" "non_prod_nodes_sg" {
  name        = "non-prod-eks-nodes-sg"
  description = "Security group for non-prod worker nodes"
  vpc_id      = aws_vpc.comet_vpc["non-prod-vpc"].id

  tags = {
    Name = "non-prod-eks-nodes-sg"
  }
}

#  Security Group for Prod Nodes
resource "aws_security_group" "prod_nodes_sg" {
  name        = "prod-eks-nodes-sg"
  description = "Security group for prod worker nodes"
  vpc_id      = aws_vpc.comet_vpc["prod-vpc"].id

  tags = {
    Name = "prod-eks-nodes-sg"
  }
}


# Allow MGMT Nodes to access NON-PROD Nodes on HTTP/HTTPS
resource "aws_security_group_rule" "non_prod_from_mgmt_http" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  security_group_id = aws_security_group.non_prod_nodes_sg.id
  source_security_group_id = aws_security_group.mgmt_nodes_sg.id
}

resource "aws_security_group_rule" "non_prod_from_mgmt_https" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.non_prod_nodes_sg.id
  source_security_group_id = aws_security_group.mgmt_nodes_sg.id
}

# Allow MGMT Nodes to access PROD Nodes on HTTP/HTTPS
resource "aws_security_group_rule" "prod_from_mgmt_http" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  security_group_id = aws_security_group.prod_nodes_sg.id
  source_security_group_id = aws_security_group.mgmt_nodes_sg.id
}

resource "aws_security_group_rule" "prod_from_mgmt_https" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.prod_nodes_sg.id
  source_security_group_id = aws_security_group.mgmt_nodes_sg.id
}



# Allow outbound access for all security groups
resource "aws_security_group_rule" "mgmt_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = aws_security_group.mgmt_nodes_sg.id
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "non_prod_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = aws_security_group.non_prod_nodes_sg.id
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "prod_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = aws_security_group.prod_nodes_sg.id
  cidr_blocks       = ["0.0.0.0/0"]
}

