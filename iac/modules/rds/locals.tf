locals {
  rds_name = "${var.project_name}-${var.environment}"
  db_name  = var.project_name
}