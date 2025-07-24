include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../../modules/vpc"
}

locals {
  globals = read_terragrunt_config(find_in_parent_folders("globals.hcl"))

  region                    = local.globals.locals.region
  environment               = local.globals.locals.environment
  project_name              = local.globals.locals.project_name
  common_tags               = local.globals.locals.common_tags

  vpc_cidr                  = local.globals.locals.vpc_cidr
  vpc_cidr_all              = local.globals.locals.vpc_cidr_all
  subnet_public_cidrs       = local.globals.locals.subnet_public_cidrs
  subnet_private_cidrs      = local.globals.locals.subnet_private_cidrs
  subnet_private_rds_cidrs  = local.globals.locals.subnet_private_rds_cidrs  
}

inputs = {
  region       = local.region
  environment  = local.environment
  project_name = local.project_name
  common_tags  = local.common_tags

  vpc_cidr = local.vpc_cidr
  vpc_cidr_all = local.vpc_cidr_all
  subnet_public_cidrs = local.subnet_public_cidrs
  subnet_private_cidrs = local.subnet_private_cidrs
  subnet_private_rds_cidrs = local.subnet_private_rds_cidrs
}