variable "aws_region" {
  description = "AWS region for the Terraform backend resources."
  type        = string
  default     = "eu-west-1"
}

variable "project_name" {
  description = "Project name used in backend resource names."
  type        = string
  default     = "capstone-phoenix"
}

variable "state_bucket_name" {
  description = "Optional globally unique S3 state bucket name. Leave empty to generate one."
  type        = string
  default     = ""
}

variable "lock_table_name" {
  description = "DynamoDB table for Terraform state locking."
  type        = string
  default     = "capstone-phoenix-tflock"
}
