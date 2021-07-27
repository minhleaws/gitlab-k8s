# environments/stag/bastion-vm/terragrunt.hcl
include {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../../modules/ssh-keypairs"
}

inputs = {
  ssh_pubkey = file("../../../../keys/gitlab-eks-sshkey.pub")
}
