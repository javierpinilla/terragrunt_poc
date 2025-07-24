data "aws_lb_listener" "alb_listener_https" {
  load_balancer_arn = var.alb_arn
  port              = 443

  timeouts {
    read = "10m"
  }
}

#data "aws_lb_listener_rule" "alb_listener_https_rules" {
#  listener_arn = data.aws_lb_listener.alb_listener_https.arn
#}

locals {
  ec2_name        = "${var.project_name}-be-${var.environment}"
  app_secret_name = "arn:aws:secretsmanager:${var.region}:${data.aws_caller_identity.current.account_id}:secret:${var.app_secret_name}/${var.environment}/${var.project_name}/*"
  rule_suffix     = replace(var.host_header, ".", "-")
  rule_name       = substr("${local.ec2_name}-re-${local.rule_suffix}", 0, 32)

  #get_priorities = try(
  #  [for rule in data.aws_lb_listener_rule.alb_listener_https_rules : rule.priority],
  #  []
  #)
  #get_priorities = try(
  #  [for rule in data.aws_lb_listener.alb_listener_https.rules : rule.priority],
  #  []
  #)
  #next_priority = length(local.get_priorities) > 0 ? max(local.get_priorities...) + 10 : 100
}