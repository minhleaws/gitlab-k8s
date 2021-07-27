# Set common variables for the environment. This is automatically pulled in in the root terragrunt.hcl configuration to
# feed forward to the child modules.
locals {
  aws_profile = "gitlab-helmchart-poc"
  aws_region  = "eu-west-1"
  environment = "poc"
  bucket_name = "gitlab-poc-terraform-backend-state"

  common_tags = {
    environment = local.environment
    role        = "gitlab-eks"
  }

  vpc_id   = "vpc-0a0f83a6b45735fdc" #vpc_core_ss
  vpc_cidr = "10.3.0.0/22"

  private_cidrs = ["10.3.3.0/24", "10.3.1.0/24"]
  public_cidrs  = ["10.3.0.0/24", "10.3.2.0/24"]

  public_subnet_ids  = ["subnet-0bc9b2c692f320310", "subnet-0f3b82770eb738118"]
  private_subnet_ids = ["subnet-0a0b81e85fc03b01f", "subnet-09f5036dee7e97385"]

}
