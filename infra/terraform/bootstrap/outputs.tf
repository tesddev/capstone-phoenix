output "state_bucket" {
  description = "S3 bucket name for the main Terraform remote state."
  value       = aws_s3_bucket.tfstate.bucket
}

output "lock_table" {
  description = "DynamoDB table name for Terraform locking."
  value       = aws_dynamodb_table.tf_lock.name
}

output "region" {
  description = "AWS region used for backend resources."
  value       = var.aws_region
}
