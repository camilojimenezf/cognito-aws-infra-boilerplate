output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = [aws_subnet.private.id, aws_subnet.private_secondary.id]
}

output "ecs_security_group_id" {
  description = "Security group ID for ECS tasks"
  value       = aws_security_group.ecs_sg.id
}

output "alb_target_group_arn" {
  description = "Target group ARN for the backend ALB"
  value       = aws_lb_target_group.backend_tg.arn
}

output "alb_dns_name" {
  description = "DNS name of the backend ALB"
  value       = aws_lb.backend_alb.dns_name
}

output "alb_zone_id" {
  description = "Zone ID of the backend ALB"
  value       = aws_lb.backend_alb.zone_id
}

output "alb_arn" {
  description = "ARN of the Application Load Balancer"
  value       = aws_lb.backend_alb.arn
}
