# ---------------------------------------------------------------------------------------------------------------------
# TERRAGRUNT CONFIGURATION
# Terragrunt is a thin wrapper for Terraform that provides extra tools for working with multiple Terraform modules,
# remote state, and locking: https://github.com/gruntwork-io/terragrunt
# ---------------------------------------------------------------------------------------------------------------------

locals {
  # Automatically load environment-level variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))

  # Extract out common variables for reuse
  env         = local.environment_vars.locals.environment
  aws_profile = local.environment_vars.locals.aws_profile
  aws_region  = local.environment_vars.locals.aws_region
  common_tags = local.environment_vars.locals.common_tags
}


generate "init_terraform" {
  path      = "init.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
terraform {
  required_version = ">= 0.13"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}
EOF
}


generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "aws" {
  profile     = "${local.aws_profile}"
  region      = "${local.aws_region}"
}
EOF
}


remote_state {
  backend = "s3"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
  config = {
    bucket = "${local.environment_vars.locals.bucket_name}"
    key    = "${path_relative_to_include()}/terraform.tfstate"
    region = local.aws_region
    profile = (
      get_env("TERRAGRUNT_DISABLE_PROFILE", "false") == "true"
      ? null
      : local.aws_profile
    )
  }
}

# Global input
inputs = {
  common_tags = local.common_tags
  namespace   = "gitlabeks"
  region      = local.aws_region
}
