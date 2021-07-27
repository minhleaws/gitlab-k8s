# environments/stag/bastion-vm/terragrunt.hcl
include {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../../modules/gitlab-s3"
}

locals {
  # Automatically load environment-level variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))

  # Extract out common variables for reuse
  environment = local.environment_vars.locals.environment
}

dependency "gitlab_eks_cluster" {
  config_path = "../gitlab-eks/eks-cluster"
}

inputs = {
  env      = local.environment
  oidc_url = dependency.gitlab_eks_cluster.outputs.oidc_url
  oidc_arn = dependency.gitlab_eks_cluster.outputs.oidc_arn
}
