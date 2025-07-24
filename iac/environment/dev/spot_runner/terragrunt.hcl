  include "root" {
  path = find_in_parent_folders("root.hcl")
}

dependency "vpc" {
  config_path = "../vpc"

  mock_outputs = {
    private_subnet_id = "private_subnet_id"
    security_group_id = "security_group_id"
  }
}

terraform {
  source = "../../../modules/spot_runner"
}

locals {
  globals = read_terragrunt_config(find_in_parent_folders("globals.hcl"))

  region        = local.globals.locals.region
  environment   = local.globals.locals.environment
  project_name  = local.globals.locals.project_name
  common_tags   = local.globals.locals.common_tags

  secret_name   = local.globals.locals.github_runner_secret_name
  instance_type = local.globals.locals.runner_instance_type
}

inputs = {
  region                    = local.region
  environment               = local.environment
  project_name              = local.project_name
  common_tags               = local.common_tags

  subnet_id                 = dependency.vpc.outputs.private_subnet_id
  security_group_id         = dependency.vpc.outputs.security_group_id

  github_runner_secret_name = local.secret_name
  instance_type             = local.instance_type
}