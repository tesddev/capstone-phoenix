resource "aws_security_group" "k3s" {
  name        = "${var.project_name}-k3s-sg"
  description = "Security group for capstone k3s nodes"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.project_name}-k3s-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "ssh_admin" {
  for_each           = toset(var.admin_cidrs)
  security_group_id  = aws_security_group.k3s.id
  description        = "SSH from admin IP ${each.value}"
  cidr_ipv4          = each.value
  from_port          = 22
  to_port            = 22
  ip_protocol        = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "k8s_api_admin" {
  for_each           = toset(var.admin_cidrs)
  security_group_id  = aws_security_group.k3s.id
  description        = "Kubernetes API from admin IP ${each.value}"
  cidr_ipv4          = each.value
  from_port          = 6443
  to_port            = 6443
  ip_protocol        = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "http_world" {
  security_group_id = aws_security_group.k3s.id
  description       = "HTTP for ingress and ACME HTTP-01"
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "https_world" {
  security_group_id = aws_security_group.k3s.id
  description       = "HTTPS for ingress"
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "node_to_node" {
  security_group_id            = aws_security_group.k3s.id
  description                  = "All private node-to-node k3s traffic inside the security group"
  referenced_security_group_id = aws_security_group.k3s.id
  ip_protocol                  = "-1"
}

resource "aws_vpc_security_group_ingress_rule" "vpc_node_to_node" {
  security_group_id = aws_security_group.k3s.id
  description       = "All private node-to-node k3s traffic inside the VPC CIDR"
  cidr_ipv4         = var.vpc_cidr
  ip_protocol       = "-1"
}

resource "aws_vpc_security_group_egress_rule" "all" {
  security_group_id = aws_security_group.k3s.id
  description       = "Outbound internet for package install, image pulls, and ACME"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}
