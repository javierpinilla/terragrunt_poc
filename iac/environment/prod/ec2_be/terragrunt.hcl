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

dependency "alb" {
  config_path = "../alb"

  mock_outputs = {
    target_group_arn  = "target_group_arn"
    alb_arn           = "alb_arn"
  }
}

terraform {
  source = "../../../modules/ec2_be"
}

locals {
  globals = read_terragrunt_config(find_in_parent_folders("globals.hcl"))

  region          = local.globals.locals.region
  environment     = local.globals.locals.environment
  project_name    = local.globals.locals.project_name
  common_tags     = local.globals.locals.common_tags

  app_secret_name     = local.globals.locals.backend_app_secret_name
  instance_type       = local.globals.locals.backend_instance_type
  host_header         = local.globals.locals.backend_host_header
  alb_prioriry_rules  = local.globals.locals.alb_prioriry_rules
}

inputs = {
  region              = local.region
  environment         = local.environment
  project_name        = local.project_name
  common_tags         = local.common_tags
  alb_prioriry_rules  = local.alb_prioriry_rules

  subnet_id           = dependency.vpc.outputs.private_subnet_id
  security_group_id   = dependency.vpc.outputs.security_group_id
  target_group_arn    = dependency.alb.outputs.target_group_arn
  alb_arn             = dependency.alb.outputs.alb_arn

  app_secret_name     = local.app_secret_name
  instance_type       = local.instance_type
  host_header         = local.host_header
}