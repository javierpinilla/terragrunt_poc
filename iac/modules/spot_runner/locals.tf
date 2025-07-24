locals {
  ec2_name       = "${var.project_name}-github_runner-${var.environment}"
  gh_secret_name = "arn:aws:secretsmanager:${var.region}:${data.aws_caller_identity.current.account_id}:secret:${var.github_runner_secret_name}*"
}