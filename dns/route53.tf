# Import the existing hosted zone that was created when you registered the domain
data "aws_route53_zone" "main" {
  name = var.domain_name
}

# ALB record - creates api domain name based on environment
resource "aws_route53_record" "alb" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = var.environment == "production" ? "api.${var.domain_name}" : "${var.environment}.api.${var.domain_name}"
  type    = "A"

  alias {
    name                   = var.alb_dns_name
    zone_id                = var.alb_zone_id
    evaluate_target_health = true
  }
}
