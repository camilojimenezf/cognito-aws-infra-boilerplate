variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "aws_access_key" {
  description = "AWS access key"
  type        = string
}

variable "aws_secret_key" {
  description = "AWS secret key"
  type        = string
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
}

variable "environment" {
  description = "Deployment environment (development, staging or production)"
  type        = string
}

variable "domain_name" {
  description = "Main domain name"
  type        = string
}

variable "db_name" {
  description = "Database name"
  type        = string
}

variable "db_username" {
  description = "Database username"
  type        = string
}

variable "db_password" {
  description = "Database password"
  type        = string
}

variable "cognito_user_pool_id" {
  description = "Cognito user pool ID"
  type        = string
}

variable "cognito_client_id" {
  description = "Cognito client ID"
  type        = string
}
