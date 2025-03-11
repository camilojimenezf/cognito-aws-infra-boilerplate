output "cloudfront_distribution_id" {
  description = "The ID of the CloudFront distribution"
  value       = aws_cloudfront_distribution.frontend_distribution.id
}

output "s3_bucket_name" {
  description = "The name of the S3 bucket for frontend"
  value       = var.s3_bucket_id
}

