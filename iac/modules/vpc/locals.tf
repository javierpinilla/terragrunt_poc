locals {
  vpc_name              = "${var.project_name}-${var.environment}-vpc"
  rds_subnet_group_name = "rds-subnetgroup-prv-${local.vpc_name}"
}