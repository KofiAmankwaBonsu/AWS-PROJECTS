output "ecr_repository_url" {
  description = "ECR repository URL"
  value       = aws_ecr_repository.app.repository_url
}

output "ecs_cluster_name" {
  description = "ECS cluster name"
  value       = aws_ecs_cluster.main.name
}

output "ecs_service_name" {
  description = "ECS service name"
  value       = aws_ecs_service.app.name
}

output "docker_push_commands" {
  description = "Commands to push Docker image to ECR"
  value = [
    "aws ecr get-login-password --region ${var.aws_region} | docker login --username AWS --password-stdin ${aws_ecr_repository.app.repository_url}",
    "docker build -t ${var.app_name} .",
    "docker tag ${var.app_name}:latest ${aws_ecr_repository.app.repository_url}:latest",
    "docker push ${aws_ecr_repository.app.repository_url}:latest"
  ]
}
