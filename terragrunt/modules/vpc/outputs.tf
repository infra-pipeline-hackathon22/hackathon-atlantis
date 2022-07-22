output "vpc_id" {
  value = module.aws_vpc.vpc_id
}

output "vpc_name" {
  value = var.vpc_name
}

output "private_subnet_ids" {
  value = module.aws_vpc.private_subnets
}
