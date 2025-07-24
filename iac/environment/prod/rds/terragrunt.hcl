include "root" {
  path = find_in_parent_folders("root.hcl")
}

dependency "vpc" {
  config_path = "../vpc"

  mock_outputs = {
    subnet_group_rds_name   = "subnet-group-name"
    security_group_rds_id   = "sg-alb-mock"
  }
}

terraform {
  source = "../../../modules/rds"
}

locals {
  globals = read_terragrunt_config(find_in_parent_folders("globals.hcl"))

  region        = local.globals.locals.region
  environment   = local.globals.locals.environment
  project_name  = local.globals.locals.project_name
  common_tags   = local.globals.locals.common_tags

  rds_instance_type = local.globals.locals.rds_instance_type
}

inputs = {
  region       = local.region
  environment  = local.environment
  project_name = local.project_name
  common_tags  = local.common_tags

  subnet_group_name = dependency.vpc.outputs.subnet_group_rds_name
  security_group_id = dependency.vpc.outputs.security_group_rds_id
  instance_class    = local.rds_instance_type
}