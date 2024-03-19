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

# module "vpc" {
#   source       = "./modules/vpc"
#   prefix       = var.prefix
#   subnet_count = 2
#   org          = var.org
#   app          = var.app
#   env          = var.env
# }

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "vpc"
  cidr = "10.0.0.0/16"

  azs             = ["us-east-1a", "us-east-1b"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]

  enable_nat_gateway = true
  enable_vpn_gateway = true

  tags = {
    org       = var.org
    app       = var.app
    env       = var.env
    terraform = true
  }
}

module "rds" {
  source   = "./modules/rds"
  org      = var.org
  app      = var.app
  env      = var.env
  vpc_id   = module.vpc.vpc_id
  subnets  = module.vpc.public_subnets
  username = "postgres"
  password = "postgres"
}

# resource "aws_cognito_user_pool" "user-pool" {
#   name = "fastfood-user-pool"

#   password_policy {
#     minimum_length    = 6
#     require_lowercase = true
#     require_numbers   = true
#     require_symbols   = true
#     require_uppercase = true
#   }
# }

# resource "aws_cognito_user_pool_client" "user-pool-client" {
#   name                   = "fastfood-user-pool-client"
#   user_pool_id           = aws_cognito_user_pool.user-pool.id
#   generate_secret        = true
#   allowed_oauth_flows    = ["code"]
#   allowed_oauth_scopes   = ["email", "openid", "profile"]
#   callback_urls          = ["http://example.com/callback"]
#   default_redirect_uri   = "http://example.com"
#   logout_urls            = ["http://example.com/logout"]
#   supported_identity_providers = ["COGNITO"]
# }

# module "eks" {
#   source            = "./modules/eks"
#   cluster_name      = var.cluster_name
#   prefix            = var.prefix
#   org               = var.org
#   app               = var.app
#   env               = var.env
#   vpc_id            = module.vpc.vpc_id
#   vpc_cidr_block    = module.vpc.vpc_cidr_block
#   subnet_ids        = module.vpc.private_subnets
#   lb_sg_id          = module.load-balancer.sg_id
#   retention_in_days = var.retention_in_days
#   instance_type     = var.instance_type
#   desired_size      = var.desired_size
#   max_size          = var.max_size
#   min_size          = var.min_size
# }

# module "target-group" {
#   source            = "./modules/target-group"
#   prefix            = var.prefix
#   org               = var.org
#   app               = var.app
#   env               = var.env
#   vpc_id            = module.vpc.vpc_id
#   target_ip_address = module.eks.cluster_id
# }

# module "load-balancer" {
#   source           = "./modules/load-balancer"
#   prefix           = var.prefix
#   vpc_id           = module.vpc.vpc_id
#   vpc_cidr_block   = module.vpc.vpc_cidr_block
#   subnet_ids       = module.vpc.private_subnets
#   target_group_arn = module.target-group.arn
#   org              = var.org
#   app              = var.app
#   env              = var.env
# }

# module "api-gateway" {
#   source          = "./modules/api-gateway"
#   prefix          = var.prefix
#   org             = var.org
#   app             = var.app
#   env             = var.env
#   subnet_ids      = module.vpc.private_subnets
#   lb_listener_arn = module.load-balancer.listener_arn
#   lb_sg_id        = module.load-balancer.sg_id
# }
