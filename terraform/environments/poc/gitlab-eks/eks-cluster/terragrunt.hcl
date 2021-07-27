# environments/stag/bastion-vm/terragrunt.hcl
include {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../../../modules/eks-cluster"
}

locals {
  # Automatically load environment-level variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))

  # Extract out common variables for reuse
  vpc_id             = local.environment_vars.locals.vpc_id
  vpc_cidr           = local.environment_vars.locals.vpc_cidr
  private_subnet_ids = local.environment_vars.locals.private_subnet_ids
  public_subnet_ids  = local.environment_vars.locals.public_subnet_ids
}

inputs = {
  vpc_id     = local.vpc_id
  subnet_ids = concat(local.private_subnet_ids, local.public_subnet_ids)

  authorized_source_ranges = ["0.0.0.0/0"]
  eks_version              = "1.18"

  egress_rules = [
    {
      id          = 1
      description = "Allow ALL"
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
      from_port   = 0
      to_port     = 0
    }
  ]

  ingress_rules = [
    {
      id          = 1
      description = "Allow within VPC"
      protocol    = "-1"
      cidr_blocks = [local.vpc_cidr]
      from_port   = 0
      to_port     = 0
    }
  ]

}
