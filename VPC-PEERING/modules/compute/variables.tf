variable "ami_id" {
  type        = string
  description = "AMI ID for the EC2 instance"
}

variable "instance_type" {
  type        = string
  description = "Instance type for the EC2 instance"
}

variable "subnet_id" {
  type        = string
  description = "Subnet ID where the instance will be launched"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID where the security group will be created"
}

variable "instance_name" {
  type        = string
  description = "Name tag for the EC2 instance"
}

variable "key_name" {
  type        = string
  description = "Name of the SSH key pair"
}

variable "peer_vpc_cidr" {
  type        = string
  description = "CIDR block of the peered VPC for ICMP access"
}
