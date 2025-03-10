// 📡 Application Load Balancer
resource "aws_lb" "backend_alb" {
  name               = "${var.project_name}-${var.environment}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets           = [aws_subnet.public.id, aws_subnet.public_secondary.id] # ALB should be in the public subnet

  tags = {
    Name = "${var.project_name}-${var.environment}-alb"
  }
}

// Create HTTP listener - HTTPS Listener is created in the DNS module after ACM certificate is validated
resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.backend_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backend_tg.arn
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-http-listener"
  }
}