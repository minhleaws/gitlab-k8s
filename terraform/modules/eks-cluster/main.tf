# ---------------------------------------------------------------------------------------------------------------------
# EKS SG
# ---------------------------------------------------------------------------------------------------------------------
locals {
  egress_rules = {
    for x in var.egress_rules : "${x.id}" => x
  }

  ingress_rules = {
    for x in var.ingress_rules : "${x.id}" => x
  }
}

#1. Create SG
resource "aws_security_group" "main" {
  name        = "${var.namespace}-eks-sg"
  vpc_id      = var.vpc_id
  description = "Communication between the control plane and worker nodegroups"

  tags = merge(
    { Name = "${var.namespace}-eks-sg" },
    var.common_tags,
  )

  lifecycle {
    create_before_destroy = true
  }
}

#2. Create Egress rules
resource "aws_security_group_rule" "egress" {
  for_each = local.egress_rules

  security_group_id        = aws_security_group.main.id
  type                     = "egress"
  description              = each.value.description
  protocol                 = each.value.protocol
  cidr_blocks              = lookup(each.value, "cidr_blocks", null)
  source_security_group_id = lookup(each.value, "source_security_group_id", null)
  from_port                = each.value.from_port
  to_port                  = each.value.to_port

  lifecycle {
    create_before_destroy = true
  }
}

#3. Create Ingress rules
resource "aws_security_group_rule" "ingress" {
  for_each = local.ingress_rules

  security_group_id        = aws_security_group.main.id
  type                     = "ingress"
  description              = each.value.description
  protocol                 = each.value.protocol
  cidr_blocks              = lookup(each.value, "cidr_blocks", null)
  source_security_group_id = lookup(each.value, "source_security_group_id", null)
  from_port                = each.value.from_port
  to_port                  = each.value.to_port

  lifecycle {
    create_before_destroy = true
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# IAM ROLE
# ---------------------------------------------------------------------------------------------------------------------

#1. Assume Role
data "aws_iam_policy_document" "main" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
  }
}

#2. IAM Role
resource "aws_iam_role" "main" {
  name               = "${var.namespace}-eks-cluster-role"
  assume_role_policy = data.aws_iam_policy_document.main.json

  tags = merge(
    { Name = "${var.namespace}-eks-cluster-role" },
    var.common_tags,
  )
}

#3. Assigne extends permission
resource "aws_iam_role_policy_attachment" "eks-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.main.name
}

resource "aws_iam_role_policy_attachment" "eks-AmazonEKSServicePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.main.name
}

# Enable Security Groups for Pods
resource "aws_iam_role_policy_attachment" "eks-AmazonEKSVPCResourceController" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.main.name
}


# ---------------------------------------------------------------------------------------------------------------------
# EKS CLUSTER
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_eks_cluster" "main" {
  name     = "${var.namespace}-eks-cluster"
  role_arn = aws_iam_role.main.arn

  version = var.eks_version

  vpc_config {
    security_group_ids      = [aws_security_group.main.id]
    endpoint_private_access = true
    endpoint_public_access  = true
    public_access_cidrs     = var.authorized_source_ranges
    subnet_ids              = var.subnet_ids
  }

  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  # Ensure that IAM Role permissions are created before and deleted after EKS Cluster handling.
  # Otherwise, EKS will not be able to properly delete EKS managed EC2 infrastructure such as Security Groups.
  depends_on = [
    aws_iam_role_policy_attachment.eks-AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.eks-AmazonEKSVPCResourceController,
    aws_iam_role_policy_attachment.eks-AmazonEKSServicePolicy
  ]


  tags = merge(
    { Name = "${var.namespace}-eks-cluster" },
    var.common_tags,
  )
}

# ---------------------------------------------------------------------------------------------------------------------
# Enabling IAM Roles for Service Accounts
# ---------------------------------------------------------------------------------------------------------------------
# https://docs.aws.amazon.com/eks/latest/userguide/enable-iam-roles-for-service-accounts.html
# https://docs.aws.amazon.com/emr/latest/EMR-on-EKS-DevelopmentGuide/setting-up-enable-IAM.html
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_cluster#enabling-iam-roles-for-service-accounts

data "tls_certificate" "main" {
  url = aws_eks_cluster.main.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "main" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.main.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.main.identity[0].oidc[0].issuer
}
