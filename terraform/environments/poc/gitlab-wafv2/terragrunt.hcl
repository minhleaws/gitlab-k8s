# environments/stag/bastion-vm/terragrunt.hcl
include {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../../modules/wafv2-rules"
}

locals {
  # Automatically load environment-level variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))

  # Extract out common variables for reuse
  aws_region = local.environment_vars.locals.aws_region
}

inputs = {
  type = "gitlab"

  wafv2_acl_rule = [
    {
      name     = "AWSManagedRulesKnownBadInputsRuleSet"
      priority = 0
    },
    {
      name          = "AWSManagedRulesCommonRuleSet"
      priority      = 1
      excluded_rule = ["GenericRFI_BODY", "SizeRestrictions_BODY"]
    },
    {
      name     = "AWSManagedRulesSQLiRuleSet"
      priority = 2
    }
  ]
}
