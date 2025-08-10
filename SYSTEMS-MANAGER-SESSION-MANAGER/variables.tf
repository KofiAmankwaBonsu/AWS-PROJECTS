variable "region" {
  description = "The region in which the resources will be deployed"
  default     = "us-west-2"

}

variable "availability_zone" {
  type        = string
  description = "Availability zone for the resources"
  default     = "us-west-2a" # replace with your desired AZ
}

variable "bucket_name" {
  type        = string
  description = "The name of the S3 bucket"
  default     = "my-session-logs-bucket6464" # replace with your desired bucket name
  
}
