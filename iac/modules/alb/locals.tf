locals {
  alb_name        = "${var.project_name}-${var.environment}-alb"
  account_id      = data.aws_caller_identity.current.account_id
  certificate_arn = "arn:aws:acm:${var.region}:${local.account_id}:certificate/${var.certificate_ssl}"
}