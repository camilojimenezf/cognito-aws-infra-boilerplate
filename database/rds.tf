resource "aws_db_instance" "postgres" {
  identifier           = "${var.project_name}-${var.environment}-rds"
  engine              = "postgres"
  engine_version      = "15"
  instance_class      = "db.t3.micro" # Adjust for production
  allocated_storage   = 20
  max_allocated_storage = 100
  storage_type        = "gp2"
  db_name             = var.db_name
  username           = var.db_username
  password           = var.db_password
  publicly_accessible = false # Ensure it's private
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.postgres_subnet_group.name
  backup_retention_period = 7
  skip_final_snapshot    = true

  tags = {
    Name        = "${var.project_name}-${var.environment}-rds"
    Environment = var.environment
  }
}
