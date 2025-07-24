output "alb_arn" {
  value = aws_lb.main.arn
}

output "alb_dns_name" {
  value = aws_lb.main.dns_name
}

output "target_group_arn" {
  value = aws_lb_target_group.app.arn
}

output "alb_subnets_used" {
  value = aws_lb.main.subnets
}

output "alb_listener_https" {
  value = aws_lb_listener.https.arn
}