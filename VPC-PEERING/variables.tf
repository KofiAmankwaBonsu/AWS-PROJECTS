variable "aws_region" {
  type = string
}
variable "requester_vpc_cidr" {
  type = string
}

variable "requester_subnet_cidr" {
  type = string
}

variable "accepter_vpc_cidr" {
  type = string
}

variable "accepter_subnet_cidr" {
  type = string
}

variable "availability_zones" {
  type = list(string)
}

variable "ami_id" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "key_name" {
  type = string
}
