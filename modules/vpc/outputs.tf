output "id" {
  value = aws_vpc.vpc.id
}

output "cidr_block" {
  value = aws_vpc.vpc.cidr_block
}

output "public_subnet_ids" {
  value = aws_subnet.vpc-public-subnets[*].id
}

output "private_subnet_ids" {
  value = aws_subnet.vpc-private-subnets[*].id
}
