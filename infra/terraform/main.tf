locals {
  name_prefix = var.project_name
}

resource "aws_key_pair" "capstone" {
  key_name   = "${local.name_prefix}-key"
  public_key = file(pathexpand(var.public_key_path))
}

module "network" {
  source = "./modules/network"

  project_name       = var.project_name
  vpc_cidr           = var.vpc_cidr
  public_subnet_cidr = var.public_subnet_cidr
  availability_zone  = var.availability_zone
}

module "security_group" {
  source = "./modules/security_group"

  project_name = var.project_name
  vpc_id       = module.network.vpc_id
  admin_cidrs  = var.admin_cidrs
  vpc_cidr     = var.vpc_cidr
}

module "compute" {
  source = "./modules/compute"

  project_name        = var.project_name
  aws_region          = var.aws_region
  subnet_id           = module.network.public_subnet_id
  security_group_id   = module.security_group.security_group_id
  key_name            = aws_key_pair.capstone.key_name
  instance_type       = var.instance_type
  worker_count        = var.worker_count
  root_volume_size_gb = var.root_volume_size_gb
}
