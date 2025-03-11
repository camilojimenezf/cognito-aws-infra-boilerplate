
# Certificate for API domains (backend/ALB)
resource "aws_acm_certificate" "api_cert" {
  domain_name = var.environment == "production" ? "api.${var.domain_name}" : "${var.environment}.api.${var.domain_name}"
  
  # No need for alternative names unless you have multiple API domains
  # subject_alternative_names = []
  
  validation_method = "DNS"
  
  tags = {
    Name        = "${var.project_name}-${var.environment}-api-certificate"
    Environment = var.environment
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Certificate validation records for API
resource "aws_route53_record" "api_cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.api_cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  zone_id = data.aws_route53_zone.main.zone_id
  name    = each.value.name
  type    = each.value.type
  records = [each.value.record]
  ttl     = 60
}

# Certificate validation for API
resource "aws_acm_certificate_validation" "api_cert" {
  certificate_arn         = aws_acm_certificate.api_cert.arn
  validation_record_fqdns = [for record in aws_route53_record.api_cert_validation : record.fqdn]
}

# ACM certificate for Frontend domains
resource "aws_acm_certificate" "cert" {
  domain_name       = var.environment == "production" ? "${var.domain_name}" : "${var.environment}.${var.domain_name}"
  subject_alternative_names = [
    var.environment == "production" ? "www.${var.domain_name}" : "www.${var.environment}.${var.domain_name}"
  ]
  validation_method = "DNS"

  tags = {
    Name        = "${var.project_name}-${var.environment}-certificate"
    Environment = var.environment
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Certificate validation records for Frontend domains
resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  zone_id = data.aws_route53_zone.main.zone_id
  name    = each.value.name
  type    = each.value.type
  records = [each.value.record]
  ttl     = 60
}

# Certificate validation for Frontend domains
resource "aws_acm_certificate_validation" "cert" {
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
}
