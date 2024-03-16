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
  region     = var.region
  access_key = var.ACCESS_KEY
  secret_key = var.SECRET_KEY
}

module "vpc" {
  source = "./modules/vpc"
  prefix = var.prefix
  org    = var.org
  app    = var.app
  env    = var.env
}

module "eks" {
  source            = "./modules/eks"
  cluster_name      = var.cluster_name 
  prefix            = var.prefix
  org               = var.org
  app               = var.app
  env               = var.env
  vpc_id            = module.vpc.id
  subnet_ids        = module.vpc.subnet_ids
  retention_in_days = var.retention_in_days
  instance_type     = var.instance_type
  desired_size      = var.desired_size
  max_size          = var.max_size
  min_size          = var.min_size
}
