
# ---------------------------------------------------------------------------------------------------------------------
# IAM ROLE
# ---------------------------------------------------------------------------------------------------------------------
#1. Assume Role
data "aws_iam_policy_document" "main" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

#2. IAM Role
resource "aws_iam_role" "main" {
  name               = "${var.namespace}-eks-nodegroup-role"
  assume_role_policy = data.aws_iam_policy_document.main.json

  tags = merge(
    { Name = "${var.namespace}-eks-nodegroup-role" },
    var.common_tags,
  )
}

#3. Assigne extends permission
resource "aws_iam_role_policy_attachment" "node-group-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.main.name
}

resource "aws_iam_role_policy_attachment" "node-group-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.main.name
}

resource "aws_iam_role_policy_attachment" "node-group-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.main.name
}

# https://docs.aws.amazon.com/eks/latest/userguide/cluster-autoscaler.html
resource "aws_iam_role_policy" "node-group-ClusterAutoscalerPolicy" {
  name_prefix = "eks-cluster-auto-scaler"
  role        = aws_iam_role.main.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "autoscaling:DescribeAutoScalingGroups",
          "autoscaling:DescribeAutoScalingInstances",
          "autoscaling:DescribeLaunchConfigurations",
          "autoscaling:DescribeTags",
          "autoscaling:SetDesiredCapacity",
          "autoscaling:TerminateInstanceInAutoScalingGroup"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

# ---------------------------------------------------------------------------------------------------------------------
# NODE GROUP
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_eks_node_group" "main" {
  cluster_name    = var.eks_cluster_name
  node_group_name = var.nodegroup_name
  node_role_arn   = aws_iam_role.main.arn
  subnet_ids      = var.subnet_ids

  labels = {
    "nodegroup_name" = var.nodegroup_name
  }

  instance_types = [var.instance_types]
  ami_type       = var.ami_type
  capacity_type  = var.capacity_type
  disk_size      = var.disk_size

  scaling_config {
    desired_size = var.desired_size
    max_size     = var.max_size
    min_size     = var.min_size
  }

  remote_access {
    ec2_ssh_key = var.ssh_keypairs
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_iam_role_policy_attachment.node-group-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.node-group-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.node-group-AmazonEC2ContainerRegistryReadOnly
  ]

  tags = merge(
    { Name = "${var.namespace}-eks-nodegroup-role" },
    var.common_tags,
  )
}
