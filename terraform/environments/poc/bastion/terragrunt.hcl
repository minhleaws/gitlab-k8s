# environments/stag/bastion-vm/terragrunt.hcl
include {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../../modules/ec2"
}

locals {
  # Automatically load environment-level variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))

  # Extract out common variables for reuse
  vpc_id            = local.environment_vars.locals.vpc_id
  public_subnet_ids = local.environment_vars.locals.public_subnet_ids
}


dependency "ssh_keypairs" {
  config_path = "../ssh-keypairs"
}

inputs = {
  type               = "bastion"
  vpc_id             = local.vpc_id
  subnet_id          = local.public_subnet_ids[0]
  associate_pulic_ip = true
  os_type            = "ubuntu" # supported os type: ubuntu, amzn2
  instance_type      = "t3.micro"
  volume_size        = "10"
  ssh_keypairs_name  = dependency.ssh_keypairs.outputs.ssh_keypairs_name

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
      description = "Allow ALL"
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
      from_port   = 0
      to_port     = 0
    }
  ]
}
