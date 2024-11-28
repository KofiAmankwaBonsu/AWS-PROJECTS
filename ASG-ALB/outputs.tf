output "vpc_information" {
  description = "VPC Information about Environment"
  value       = "Your ${aws_vpc.vpc.tags.Environment} VPC has an ID of ${aws_vpc.vpc.id}"
}

# If you want to output Subnet ids as a list 
output "public_subnet_ids_list" {
  description = "List of public subnet IDs"
  value       = [for subnet in aws_subnet.public_subnets : subnet.id]
}
