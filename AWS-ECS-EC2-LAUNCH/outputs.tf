output "alb_dns_name" {
  description = "DNS name of the load balancer"
  value       = aws_lb.app.dns_name
}

output "ecr_repository_url" {
  description = "URL of the ECR repository"
  value       = aws_ecr_repository.app.repository_url
}

output "docker_commands" {
  description = "Commands to build and push Docker image"
  value = <<-EOT
    # 1. Get ECR login token
    aws ecr get-login-password --region ${var.aws_region} | docker login --username AWS --password-stdin ${aws_ecr_repository.app.repository_url}
    
    # 2. Build Docker image
    docker build -t ${var.app_name} .
    
    # 3. Tag image for ECR
    docker tag ${var.app_name}:latest ${aws_ecr_repository.app.repository_url}:latest
    
    # 4. Push image to ECR
    docker push ${aws_ecr_repository.app.repository_url}:latest

   # 5. Force ECS service update (optional)
    aws ecs update-service --cluster ${aws_ecs_cluster.main.name} --service ${aws_ecs_service.app.name} --force-new-deployment --region ${var.aws_region} 

    
  EOT
}


