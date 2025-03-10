# CloudFront record for frontend
resource "aws_route53_record" "frontend" {
  zone_id = var.route53_zone_id
  name    = var.environment == "production" ? "www.${var.domain_name}" : "www.${var.environment}.${var.domain_name}"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.frontend_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.frontend_distribution.hosted_zone_id
    evaluate_target_health = false
  }
}

# CloudFront record for frontend (non-www version)
resource "aws_route53_record" "frontend_no_www" {
  zone_id = var.route53_zone_id
  name    = var.environment == "production" ? "${var.domain_name}" : "${var.environment}.${var.domain_name}"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.frontend_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.frontend_distribution.hosted_zone_id
    evaluate_target_health = false
  }
}