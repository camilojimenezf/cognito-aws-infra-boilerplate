resource "aws_ecr_repository" "backend_repo" {
  name = "${var.project_name}-${var.environment}-backend"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = "${var.project_name}-backend"
    Environment = var.environment
  }
}
