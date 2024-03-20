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
  source = "terraform-aws-modules/vpc/aws"

  name = "vpc"
  cidr = "10.0.0.0/16"

  azs             = ["us-east-1a", "us-east-1b"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]
  intra_subnets   = ["10.0.201.0/24", "10.0.202.0/24"]

  enable_nat_gateway = true
  enable_dns_hostnames = true
  enable_dns_support = true

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

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = "${var.app}-${var.env}-cluster"
  cluster_version = "1.29"

  cluster_endpoint_public_access = true

  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
  }

  vpc_id                   = module.vpc.vpc_id
  subnet_ids               = module.vpc.private_subnets
  control_plane_subnet_ids = module.vpc.intra_subnets

  eks_managed_node_group_defaults = {
    ami_type                              = "AL2_x86_64"
    instance_types                        = [var.instance_type]
    capacity_type                         = "SPOT"
    disk_size                             = 30
    attach_cluster_primary_security_group = true
  }

  eks_managed_node_groups = {
    example = {
      min_size     = var.min_size
      max_size     = var.max_size
      desired_size = var.desired_size

      instance_types = [var.instance_type]
      capacity_type  = "SPOT"
    }
  }

  node_security_group_tags = {
    "kubernetes.io/cluster/${var.app}" = null
  }

  enable_cluster_creator_admin_permissions = true

  tags = {
    org       = var.org
    app       = var.app
    env       = var.env
    terraform = true
  }
}
