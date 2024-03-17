terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  backend "s3" {
    bucket = "fiap-fastfood"
    key    = "terraform.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  region = var.region
}

module "vpc" {
  source       = "./modules/vpc"
  prefix       = var.prefix
  subnet_count = 2
  org          = var.org
  app          = var.app
  env          = var.env
}

module "eks" {
  source            = "./modules/eks"
  cluster_name      = var.cluster_name
  prefix            = var.prefix
  org               = var.org
  app               = var.app
  env               = var.env
  vpc_id            = module.vpc.id
  vpc_cidr_block    = module.vpc.cidr_block
  subnet_ids        = module.vpc.private_subnet_ids
  lb_sg_id          = module.load-balancer.sg_id
  retention_in_days = var.retention_in_days
  instance_type     = var.instance_type
  desired_size      = var.desired_size
  max_size          = var.max_size
  min_size          = var.min_size
}

module "target-group" {
  source            = "./modules/target-group"
  prefix            = var.prefix
  org               = var.org
  app               = var.app
  env               = var.env
  vpc_id            = module.vpc.id
  target_ip_address = module.eks.cluster_id
}

module "load-balancer" {
  source           = "./modules/load-balancer"
  prefix           = var.prefix
  vpc_id           = module.vpc.id
  vpc_cidr_block   = module.vpc.cidr_block
  subnet_ids       = module.vpc.private_subnet_ids
  target_group_arn = module.target-group.arn
  org              = var.org
  app              = var.app
  env              = var.env
}

module "api-gateway" {
  source          = "./modules/api-gateway"
  prefix          = var.prefix
  org             = var.org
  app             = var.app
  env             = var.env
  subnet_ids      = module.vpc.private_subnet_ids
  lb_listener_arn = module.load-balancer.listener_arn
  lb_sg_id        = module.load-balancer.sg_id
}
