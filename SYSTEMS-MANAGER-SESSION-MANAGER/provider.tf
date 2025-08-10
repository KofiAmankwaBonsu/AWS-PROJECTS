provider "aws" {
  region = var.region
}

# Data source for current region
data "aws_region" "current" {}

# Data source for current identity
data "aws_caller_identity" "current" {}
