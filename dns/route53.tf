# Domain zone (create or import existing)
resource "aws_route53_zone" "main" {
  name = var.domain_name
}

// Register the domain to avoid changes in NS records when creating the ACM certificate
resource "aws_route53domains_registered_domain" "main" {
  domain_name = var.domain_name

  name_server {
    name = aws_route53_zone.main.name_servers[0]
  }

  name_server {
    name = aws_route53_zone.main.name_servers[1]
  }

  name_server {
    name = aws_route53_zone.main.name_servers[2]
  }

  name_server {
    name = aws_route53_zone.main.name_servers[3]
  }
}

# ALB record - creates api domain name based on environment
resource "aws_route53_record" "alb" {
  zone_id = aws_route53_zone.main.zone_id
  name    = var.environment == "production" ? "api.${var.domain_name}" : "${var.environment}.api.${var.domain_name}"
  type    = "A"

  alias {
    name                   = var.alb_dns_name
    zone_id                = var.alb_zone_id
    evaluate_target_health = true
  }
}
