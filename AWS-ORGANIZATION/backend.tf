terraform {
  backend "s3" {
    bucket = "bucket-name"
    key    = "aws-org-accounts/terraform.tfstate"
    region = "us-east-1"
  }
}