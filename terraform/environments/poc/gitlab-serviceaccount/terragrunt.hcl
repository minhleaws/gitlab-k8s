# environments/stag/bastion-vm/terragrunt.hcl
include {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../../modules/iam-role-sa-eks"
}

locals {
  # Automatically load environment-level variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))

  # Extract out common variables for reuse
  aws_profile = local.environment_vars.locals.aws_profile
}

dependency "gitlab_eks_cluster" {
  config_path = "../gitlab-eks/eks-cluster"
}

dependency "gitlab_s3" {
  config_path = "../gitlab-s3"
}

inputs = {
  oidc_url                          = dependency.gitlab_eks_cluster.outputs.oidc_url
  oidc_arn                          = dependency.gitlab_eks_cluster.outputs.oidc_arn
  eks_cluster_name                  = dependency.gitlab_eks_cluster.outputs.cluster_name
  eks_cluster_endpoint              = dependency.gitlab_eks_cluster.outputs.endpoint
  eks_cluster_certificate_authority = dependency.gitlab_eks_cluster.outputs.kubeconfig-certificate-authority-data

  kube_namespace = "gitlabeks"
  kube_sa_name   = "gitlabeks-sa-aws-access"

  aws_profile = local.aws_profile

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:ListBucket",
          "s3:GetBucketLocation",
          "s3:ListBucketMultipartUploads",
        ]
        Effect = "Allow"
        Resource = [
          dependency.gitlab_s3.outputs.gitlab_backups_bucket_arn,
          dependency.gitlab_s3.outputs.gitlab_tmp_bucket_arn,
          dependency.gitlab_s3.outputs.gitlab_runner_cache_bucket_arn,
          dependency.gitlab_s3.outputs.gitlab_pseudo_bucket_arn,
          dependency.gitlab_s3.outputs.gitlab_lfs_bucket_arn,
          dependency.gitlab_s3.outputs.gitlab_artifacts_bucket_arn,
          dependency.gitlab_s3.outputs.gitlab_uploads_bucket_arn,
          dependency.gitlab_s3.outputs.gitlab_packages_bucket_arn,
          dependency.gitlab_s3.outputs.gitlab_dependency_proxy_bucket_arn,
          dependency.gitlab_s3.outputs.gitlab_mr_diffs_bucket_arn,
          dependency.gitlab_s3.outputs.gitlab_terraform_state_bucket_arn,
          dependency.gitlab_s3.outputs.gitlab_pages_bucket_arn,
          dependency.gitlab_s3.outputs.gitlab_registry_bucket_arn,
        ]
      },
      {
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:DeleteObject",
          "s3:ListMultipartUploadParts",
          "s3:AbortMultipartUpload",
          "s3:ListBucketMultipartUploads"
        ]
        Effect = "Allow"
        Resource = [
          "${dependency.gitlab_s3.outputs.gitlab_backups_bucket_arn}/*",
          "${dependency.gitlab_s3.outputs.gitlab_tmp_bucket_arn}/*",
          "${dependency.gitlab_s3.outputs.gitlab_runner_cache_bucket_arn}/*",
          "${dependency.gitlab_s3.outputs.gitlab_pseudo_bucket_arn}/*",
          "${dependency.gitlab_s3.outputs.gitlab_lfs_bucket_arn}/*",
          "${dependency.gitlab_s3.outputs.gitlab_artifacts_bucket_arn}/*",
          "${dependency.gitlab_s3.outputs.gitlab_uploads_bucket_arn}/*",
          "${dependency.gitlab_s3.outputs.gitlab_packages_bucket_arn}/*",
          "${dependency.gitlab_s3.outputs.gitlab_dependency_proxy_bucket_arn}/*",
          "${dependency.gitlab_s3.outputs.gitlab_mr_diffs_bucket_arn}/*",
          "${dependency.gitlab_s3.outputs.gitlab_terraform_state_bucket_arn}/*",
          "${dependency.gitlab_s3.outputs.gitlab_pages_bucket_arn}/*",
          "${dependency.gitlab_s3.outputs.gitlab_registry_bucket_arn}/*"
        ]
      }
    ]
  })
}
