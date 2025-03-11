output "db_endpoint" {
  description = "The connection endpoint for the database"
  value       = aws_db_instance.postgres.address
}

output "db_name" {
  description = "The database name"
  value       = aws_db_instance.postgres.db_name
}

output "db_username" {
  description = "The database username"
  value       = aws_db_instance.postgres.username
}

output "db_password" {
  description = "The database password"
  value       = var.db_password
  sensitive   = true
}