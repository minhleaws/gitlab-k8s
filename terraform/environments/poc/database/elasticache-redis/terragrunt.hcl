# environments/stag/bastion-vm/terragrunt.hcl
include {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../../../modules/elasticache-redis"
}

locals {
  # Automatically load environment-level variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))

  # Extract out common variables for reuse
  vpc_id             = local.environment_vars.locals.vpc_id
  vpc_cidr           = local.environment_vars.locals.vpc_cidr
  private_subnet_ids = local.environment_vars.locals.private_subnet_ids
}


dependency "bastion" {
  config_path = "../../bastion"
}

inputs = {
  vpc_id                     = local.vpc_id
  subnet_ids                 = local.private_subnet_ids
  family                     = "redis5.0"
  engine_version             = "5.0.6"
  node_type                  = "cache.t3.small"
  number_cache_clusters      = 1
  automatic_failover_enabled = false
  multi_az_enabled           = false

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
      id                       = 1
      description              = "Allow Bastion"
      protocol                 = "TCP"
      source_security_group_id = dependency.bastion.outputs.security_group_id
      from_port                = 6379
      to_port                  = 6379
    },
    {
      id          = 2
      description = "Allow VPC"
      protocol    = "TCP"
      cidr_blocks = ["${local.vpc_cidr}"]
      from_port   = 6379
      to_port     = 6379
    }
  ]
}
