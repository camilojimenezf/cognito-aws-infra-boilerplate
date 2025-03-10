// 📦 ECS cluster
resource "aws_ecs_cluster" "backend_cluster" {
  name = "${var.project_name}-${var.environment}-backend-cluster"

  tags = {
    Name = "${var.project_name}-${var.environment}-ecs-cluster"
    Environment = var.environment
  }
}

// 📦 ECS task definition
resource "aws_ecs_task_definition" "backend_task" {
  depends_on = [aws_ecr_repository.backend_repo]

  family                   = "${var.project_name}-${var.environment}-backend-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  cpu                      = "512"  # Adjust as needed
  memory                   = "1024" # Adjust as needed

  container_definitions = jsonencode([
    {
      name      = "nestjs-backend"
      image     = "${aws_ecr_repository.backend_repo.repository_url}:latest"
      cpu       = 512
      memory    = 1024
      essential = true
      portMappings = [
        {
          containerPort = 3000
          hostPort      = 3000
        }
      ]
      environment = [
        { name = "NODE_ENV", value = var.environment },
        { name = "PORT", value = "3000" },
        { name = "COGNITO_USER_POOL_ID", value = var.cognito_user_pool_id },
        { name = "COGNITO_CLIENT_ID", value = var.cognito_client_id },
        { name = "DB_PASSWORD", value = var.db_password },
        { name = "DB_NAME", value = var.db_name },
        { name = "DB_HOST", value = var.db_host },
        { name = "DB_PORT", value = var.db_port },
        { name = "DB_USERNAME", value = var.db_username },
        { name = "DB_SSL", value = "true" }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/${var.project_name}-${var.environment}-backend"
          "awslogs-region"        = "us-east-1"  # Adjust to your region
          "awslogs-stream-prefix" = "nestjs"
          "awslogs-create-group"  = "true"  # Auto-create the log group
        }
      }
    }
  ])
}

// 📦 ECS service
resource "aws_ecs_service" "backend_service" {
  name            = "${var.project_name}-${var.environment}-backend-service"
  cluster         = aws_ecs_cluster.backend_cluster.id
  task_definition = aws_ecs_task_definition.backend_task.arn
  launch_type     = "FARGATE"
  desired_count   = 1

  network_configuration {
    subnets          = var.private_subnet_ids # Private subnet
    security_groups  = [var.ecs_security_group]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.alb_target_group_arn
    container_name   = "nestjs-backend"
    container_port   = 3000
  }
}

// 📦 IAM role for ECS task execution
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "${var.project_name}-${var.environment}-ecs-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "${var.project_name}-${var.environment}-ecs-execution-role"
    Environment = var.environment
  }
}

// 📦 Attach the AWS managed policy to the ECS task execution
resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

// 📦 Attach the logging policy to the ECS task execution
resource "aws_iam_role_policy" "ecs_logging_policy" {
  name   = "${var.project_name}-${var.environment}-ecs-logging-policy"
  role   = aws_iam_role.ecs_task_execution_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/ecs/${var.project_name}-${var.environment}-backend:*"
      }
    ]
  })
}

data "aws_region" "current" {}
data "aws_caller_identity" "current" {}