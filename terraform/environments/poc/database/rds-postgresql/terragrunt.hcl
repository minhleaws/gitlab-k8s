# environments/stag/bastion-vm/terragrunt.hcl
include {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../../../modules/rds-postgresql"
}

locals {
  # Automatically load environment-level variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  secret_vars      = yamldecode(sops_decrypt_file(find_in_parent_folders("secrets.yaml")))

  # Extract out common variables for reuse
  vpc_id               = local.environment_vars.locals.vpc_id
  vpc_cidr             = local.environment_vars.locals.vpc_cidr
  private_subnet_ids   = local.environment_vars.locals.private_subnet_ids
  postgres_db_password = local.secret_vars.postgres_db_password

}

dependency "bastion" {
  config_path = "../../bastion"
}


inputs = {
  vpc_id     = local.vpc_id
  subnet_ids = local.private_subnet_ids

  family         = "postgres12"
  engine_version = "12.5"

  instance_class        = "db.t3.small"
  allocated_storage     = 30   #GB
  max_allocated_storage = 1000 #GB
  storage_type          = "gp2"

  db_name     = "gitlabhq_production"
  db_username = "gitlab"
  db_password = local.postgres_db_password

  multi_az = true

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
      from_port                = 5432
      to_port                  = 5432
    },
    {
      id          = 2
      description = "Allow VPC"
      protocol    = "TCP"
      cidr_blocks = ["${local.vpc_cidr}"]
      from_port   = 5432
      to_port     = 5432
    }
  ]
}
