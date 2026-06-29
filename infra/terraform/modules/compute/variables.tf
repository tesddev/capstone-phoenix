variable "project_name" { type = string }
variable "aws_region" { type = string }
variable "subnet_id" { type = string }
variable "security_group_id" { type = string }
variable "key_name" { type = string }
variable "instance_type" { type = string }
variable "worker_count" { type = number }
variable "root_volume_size_gb" { type = number }
