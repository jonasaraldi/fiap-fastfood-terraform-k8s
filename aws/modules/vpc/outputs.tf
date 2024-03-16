output "id" {
  value = aws_vpc.vpc.id
}

output "subnet_ids" {
  value = aws_subnet.vpc-subnets[*].id
}
