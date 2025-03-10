output "s3_bucket_domain_name" {
  value = aws_s3_bucket.frontend_bucket.bucket_regional_domain_name
}

output "s3_bucket_id" {
  value = aws_s3_bucket.frontend_bucket.id
}

output "s3_bucket_arn" {
  value = aws_s3_bucket.frontend_bucket.arn
}
