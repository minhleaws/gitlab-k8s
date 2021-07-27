# ---------------------------------------------------------------------------------------------------------------------
# IAM Roles for Service Accounts EKS
# ---------------------------------------------------------------------------------------------------------------------

provider "kubernetes" {
  host = var.eks_cluster_endpoint

  cluster_ca_certificate = base64decode(var.eks_cluster_certificate_authority)

  exec {
    api_version = "client.authentication.k8s.io/v1alpha1"
    args        = ["eks", "get-token", "--cluster-name", var.eks_cluster_name, "--profile", var.aws_profile]
    command     = "aws"
  }
}


#1. Create namespace
resource "kubernetes_namespace" "main" {
  metadata {
    name = var.kube_namespace
  }
}


#2. Create IAM Role
resource "aws_iam_role" "main" {
  name = "${var.namespace}-eks-serviceaccount-role"

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Federated" : var.oidc_arn
        },
        "Action" : "sts:AssumeRoleWithWebIdentity",
        "Condition" : {
          "StringEquals" : {
            "${replace(var.oidc_url, "https://", "")}:sub" : "system:serviceaccount:${var.kube_namespace}:${var.kube_sa_name}"
          }
        }
      }
    ]
  })

  tags = merge(
    { Name = "${var.namespace}-eks-serviceaccount-role" },
    var.common_tags,
  )
}


resource "aws_iam_role_policy" "main" {
  name = "${var.namespace}-eks-serviceaccount-policy"
  role = aws_iam_role.main.id

  policy = var.policy
}

## IMPORTANCE
/*
Using the backup-utility as specified in the backup documentation
does not properly copy the backup file to the S3 bucket. The backup-utility uses
the s3cmd to perform the copy of the backup file and it has a known
issue of not supporting OIDC authentication.
*/
# https://gitlab.com/gitlab-org/charts/gitlab/-/blob/v5.1.0/doc/advanced/external-object-storage/aws-iam-roles.md#using-iam-roles-for-service-accounts
# https://github.com/s3tools/s3cmd/pull/1112
# https://github.com/s3tools/s3cmd/milestone/3?closed=1

# Workaround: IAM access key & secrets

resource "aws_iam_user" "main" {
  name = "${var.namespace}-eks-serviceaccount"
  path = "/system/"
}

resource "aws_iam_access_key" "main" {
  user = aws_iam_user.main.name
}

resource "aws_iam_user_policy" "main" {
  user   = aws_iam_user.main.name
  policy = var.policy
}


#3. Create a Kubernetes service account
resource "kubernetes_service_account" "main" {
  metadata {
    name      = var.kube_sa_name
    namespace = var.kube_namespace

    labels = {
      "app.kubernetes.io/name" = "aws-access"
    }
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.main.arn
    }
  }
}
