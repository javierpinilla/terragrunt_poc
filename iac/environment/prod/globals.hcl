locals {
  environment               = "prd"
  region                    = "us-east-1"
  owner                     = "Devops"
  project_name              = "clinical_test"

  vpc_cidr                  = "10.60.0.0/16"
  vpc_cidr_all              = "0.0.0.0/0"
  subnet_public_cidrs       = ["10.60.1.0/24", "10.60.2.0/24", "10.60.3.0/24"]
  subnet_private_cidrs      = ["10.60.21.0/24", "10.60.22.0/24", "10.60.23.0/24"]
  subnet_private_rds_cidrs  = ["10.60.41.0/24", "10.60.42.0/24", "10.60.43.0/24"]
  rds_instance_type         = "db.t4g.micro"
  alb_certificate_ssl       = "82d49abb-eeaa-4a64-bd9b-a253735dface"
  runner_instance_type      = "t3.micro"
  github_runner_secret_name = "admin/github_runner_secret"
  backend_app_secret_name   = "app"
  backend_instance_type     = "t3a.micro"
  backend_host_header       = "api.example.com"
  alb_prioriry_rules        = 100

  common_tags = {
    Project     = local.project_name
    Environment = local.environment
    Owner       = local.owner
  }
}