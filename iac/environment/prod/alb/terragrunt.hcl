include "root" {
  path = find_in_parent_folders("root.hcl")
}

dependency "vpc" {
  config_path = "../vpc"

  mock_outputs = {
    vpc_id                  = "vpc-mock-id"
    public_subnet_id        = ["subnet-1", "subnet-2", "subnet-3"]
    security_group_alb_id   = "sg-alb-mock"
  }
}

terraform {
  source = "../../../modules/alb"
}

locals {
  globals = read_terragrunt_config(find_in_parent_folders("globals.hcl"))

  region          = local.globals.locals.region
  environment     = local.globals.locals.environment
  project_name    = local.globals.locals.project_name
  common_tags     = local.globals.locals.common_tags

  certificate_ssl = local.globals.locals.alb_certificate_ssl
}

inputs = {
  region       = local.region
  environment  = local.environment
  project_name = local.project_name
  common_tags  = local.common_tags

  vpc_id = dependency.vpc.outputs.vpc_id
  subnet_id = dependency.vpc.outputs.public_subnet_id
  security_group_id = dependency.vpc.outputs.security_group_alb_id

  certificate_ssl = local.certificate_ssl
}