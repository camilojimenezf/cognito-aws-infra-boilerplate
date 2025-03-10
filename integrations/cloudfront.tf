resource "aws_cloudfront_distribution" "frontend_distribution" {
  origin {
    domain_name = var.s3_bucket_domain_name
    origin_id   = "S3-${var.s3_bucket_id}"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.frontend_oai.cloudfront_access_identity_path
    }
  }

  enabled = true
  default_root_object = "index.html"

  # Cache behavior
  default_cache_behavior {
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "S3-${var.s3_bucket_id}"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }

  custom_error_response {
    error_code = 403
    response_code = 200
    response_page_path = "/index.html"
  }
  
  custom_error_response {
    error_code = 404
    response_code = 200
    response_page_path = "/index.html"
  }
  
  price_class = "PriceClass_All"
  
  viewer_certificate {
    acm_certificate_arn = var.certificate_arn
    ssl_support_method = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-cloudfront"
    Environment = var.environment
  }

  aliases = [
    var.environment == "production" ? "${var.domain_name}" : "${var.environment}.${var.domain_name}",
    var.environment == "production" ? "www.${var.domain_name}" : "www.${var.environment}.${var.domain_name}"
  ]
}

resource "aws_cloudfront_origin_access_identity" "frontend_oai" {
  comment = "OAI for accessing S3 frontend bucket"
}

# 📜 S3 bucket policy for CloudFront access
resource "aws_s3_bucket_policy" "frontend_bucket_policy" {
  bucket = var.s3_bucket_id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = aws_cloudfront_origin_access_identity.frontend_oai.iam_arn
        }
        Action = "s3:GetObject"
        Resource = "${var.s3_bucket_arn}/*"
      }
    ]
  })
}