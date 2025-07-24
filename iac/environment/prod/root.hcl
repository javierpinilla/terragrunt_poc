locals {
  globals = read_terragrunt_config(find_in_parent_folders("globals.hcl"))

  region        = local.globals.locals.region
  environment   = local.globals.locals.environment
  project_name  = local.globals.locals.project_name
}

remote_state {
  backend = "s3"
  config = {
    bucket         = "wellcentra-infra-state"
    key            = "terraform/${local.project_name}/${local.region}/${local.environment}/${path_relative_to_include()}/terraform.tfstate"
    region         = local.region
    encrypt        = true
    use_lockfile   = true
  }
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "aws" {
  region = "${local.region}"
}
EOF
}