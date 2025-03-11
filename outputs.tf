# ECR/ECS outputs
output "ecr_repository_url" {
  description = "The URL of the ECR repository"
  value       = module.compute.ecr_repository_url
}

output "ecs_cluster_name" {
  description = "The name of the ECS cluster"
  value       = module.compute.ecs_cluster_name
}

output "ecs_service_name" {
  description = "The name of the ECS service"
  value       = module.compute.ecs_service_name
}

# S3/CloudFront outputs
output "s3_bucket_name" {
  description = "The name of the S3 bucket for frontend"
  value       = module.storage.s3_bucket_id
}

output "cloudfront_distribution_id" {
  description = "The ID of the CloudFront distribution"
  value       = module.integrations.cloudfront_distribution_id
}

# URLs
output "api_url" {
  description = "The URL for the backend API"
  value       = var.environment == "production" ? "https://api.${var.domain_name}" : "https://${var.environment}.api.${var.domain_name}"
}

output "app_url" {
  description = "The URL for the frontend application"
  value       = var.environment == "production" ? "https://${var.domain_name}" : "https://${var.environment}.${var.domain_name}"
}