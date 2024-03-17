variable "prefix" {}
variable "org" {}
variable "app" {}
variable "env" {}

variable "vpc_id" {}
variable "vpc_cidr_block" {}
variable "subnet_ids" {}
variable "lb_sg_id" {}

variable "retention_in_days" {}

variable "cluster_name" {}
variable "desired_size" {}
variable "max_size" {}
variable "min_size" {}
variable "instance_type" {}
