# environments/stag/bastion-vm/terragrunt.hcl
include {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../../../modules/eks-nodegroup"
}

locals {
  # Automatically load environment-level variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))

  # Extract out common variables for reuse
  private_subnet_ids = local.environment_vars.locals.private_subnet_ids
}


dependency "ssh_keypairs" {
  config_path = "../../ssh-keypairs"
}

dependency "eks_cluster" {
  config_path = "../eks-cluster"
}

inputs = {
  subnet_ids       = local.private_subnet_ids
  eks_cluster_name = dependency.eks_cluster.outputs.cluster_name
  ssh_keypairs     = dependency.ssh_keypairs.outputs.ssh_keypairs_name
  nodegroup_name   = "gitlabeks-node-gr01"

  desired_size   = 2
  max_size       = 4
  min_size       = 2
  disk_size      = 30 #GB
  instance_types = "c5.xlarge"
  ami_type       = "AL2_x86_64"
  capacity_type  = "ON_DEMAND" # ON_DEMAND or SPOT

}
