
// 📡 HTTPS Listener
resource "aws_lb_listener" "https_listener" {
  load_balancer_arn = var.alb_arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate.api_cert.arn

  default_action {
    type             = "forward"
    target_group_arn = var.alb_target_group_arn
  }

  depends_on = [aws_acm_certificate_validation.api_cert]  // Wait for validation
}

// 📡 Fetch existing HTTP listener
data "aws_lb_listener" "existing_http_listener" {
  load_balancer_arn = var.alb_arn
  port              = 80

  tags = {
    Name = "${var.project_name}-${var.environment}-http-listener"
  }
}

// 📡 Add HTTP Listener rule to redirect to HTTPS
resource "aws_lb_listener_rule" "http_redirect" {
  listener_arn = data.aws_lb_listener.existing_http_listener.arn
  priority     = 1

  action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }

  condition {
    path_pattern {
      values = ["*"]
    }
  }

  depends_on = [aws_lb_listener.https_listener]
}