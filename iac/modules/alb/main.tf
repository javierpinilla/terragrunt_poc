data "aws_caller_identity" "current" {}

resource "aws_lb" "main" {
  name               = local.alb_name
  internal           = false
  load_balancer_type = "application"
  subnets            = var.subnet_id
  security_groups    = [var.security_group_id]

  tags = merge(var.common_tags, {
    Name = local.alb_name
  })
}

# Alb Target Group
resource "aws_lb_target_group" "app" {
  name     = "tg-be-${local.alb_name}"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path                = "/"
    matcher             = "200-299"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    protocol            = "HTTP"
    port                = "8080"
  }
}

# Listener HTTP
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
      host        = "#{host}"
      path        = "/#{path}"
      query       = "#query"
    }
  }
}

# Listener HTTPS
resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.main.arn
  port              = 443
  protocol          = "HTTPS"
  certificate_arn   = local.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }
}

# Forzar http to https
#resource "aws_lb_listener_rule" "hsts" {
#  listener_arn = aws_lb_listener.https.arn
#  priority     = 1
#
#  action {
#    type = "fixed-response"
#
#    fixed_response {
#      content_type = "text/plain"
#      message_body = "Redirecting to HTTPS"
#      status_code  = "426"
#    }
#  }
#
#  condition {
#    http_header {
#      http_header_name = "X-Forwarded-Proto"
#      values           = ["HTTP"]
#    }
#  }
#}