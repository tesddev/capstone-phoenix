variable "project_name" {
  description = "Project name used for resource names."
  type        = string
  default     = "capstone-phoenix"
}

variable "aws_region" {
  description = "AWS region to provision into."
  type        = string
  default     = "eu-west-1"
}

variable "availability_zone" {
  description = "Availability zone for the low-cost single-subnet cluster."
  type        = string
  default     = "eu-west-1a"
}

variable "admin_cidrs" {
  description = "List of admin public IPs in CIDR form, for SSH and Kubernetes API access. Example: [\"203.0.113.10/32\", \"203.0.113.11/32\"]"
  type        = list(string)
}

variable "public_key_path" {
  description = "Path to the public SSH key Terraform imports into AWS."
  type        = string
  default     = "~/.ssh/capstone-phoenix.pub"
}

variable "instance_type" {
  description = "EC2 size for all k3s nodes. t3.micro is cost-optimized but tight."
  type        = string
  default     = "t3.micro"
}

variable "worker_count" {
  description = "Number of worker nodes. The brief requires at least 2."
  type        = number
  default     = 2

  validation {
    condition     = var.worker_count >= 2
    error_message = "worker_count must be at least 2 for the capstone."
  }
}

variable "vpc_cidr" {
  description = "CIDR for the VPC."
  type        = string
  default     = "10.42.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR for the public subnet containing all nodes."
  type        = string
  default     = "10.42.1.0/24"
}

variable "root_volume_size_gb" {
  description = "Root EBS volume size for each node."
  type        = number
  default     = 20
}

variable "default_tags" {
  description = "Tags applied to all supported AWS resources."
  type        = map(string)
  default = {
    Project   = "capstone-phoenix"
    ManagedBy = "terraform"
    Owner     = "tesddev"
  }
}
