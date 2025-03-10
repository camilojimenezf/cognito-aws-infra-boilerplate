resource "aws_s3_bucket" "frontend_bucket" {
  bucket = "${var.project_name}-${var.environment}-frontend"
  force_destroy = true # Allow deleting the bucket when destroying infra (only for testing)
  tags = {
    Name = "${var.project_name}-${var.environment}-frontend"
    Environment = var.environment
  }
}

# 🔐 Block public access to the S3 bucket
resource "aws_s3_bucket_public_access_block" "frontend_bucket" {
  bucket                  = aws_s3_bucket.frontend_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# 🔄 Enable versioning for rollback support (optional)
resource "aws_s3_bucket_versioning" "frontend_bucket" {
  bucket = aws_s3_bucket.frontend_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}
