data "aws_availability_zones" "available" {}

locals {
  azs = slice(data.aws_availability_zones.available.names, 0, 3)
}

module "aws_vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 3.0"

  name = var.vpc_name
  cidr = var.vpc_ipv4_cidr
  azs  = local.azs

  enable_ipv6                                    = true
  assign_ipv6_address_on_creation                = true # Assign IPv6 address on subnet, must be disabled to change IPv6 CIDRs. This is the IPv6 equivalent of map_public_ip_on_launch
  private_subnet_assign_ipv6_address_on_creation = true # Assign IPv6 address on private subnet, must be disabled to change IPv6 CIDRs. This is the IPv6 equivalent of map_public_ip_on_launch

  public_subnet_ipv6_prefixes  = [0, 1, 2] # Assigns IPv6 private subnet id based on the Amazon provided /56 prefix base 10 integer (0-256). Must be of equal length to the corresponding IPv4 subnet list
  private_subnet_ipv6_prefixes = [3, 4, 5] # Assigns IPv6 public subnet id based on the Amazon provided /56 prefix base 10 integer (0-256). Must be of equal length to the corresponding IPv4 subnet list

  public_subnets  = [for k, v in local.azs : cidrsubnet(var.vpc_ipv4_cidr, 8, k)]
  private_subnets = [for k, v in local.azs : cidrsubnet(var.vpc_ipv4_cidr, 8, k + 10)]

  enable_nat_gateway   = true
  single_nat_gateway   = true
  create_igw           = true
  enable_dns_hostnames = true

  # Manage so we can name
  manage_default_network_acl    = true
  default_network_acl_tags      = { Name = "${var.vpc_name}-default" }
  manage_default_route_table    = true
  default_route_table_tags      = { Name = "${var.vpc_name}-default" }
  manage_default_security_group = true
  default_security_group_tags   = { Name = "${var.vpc_name}-default" }

  public_subnet_tags = merge(flatten([
    [for name in var.eks_cluster_names : { "kubernetes.io/cluster/${name}" = "shared" }],
    { "kubernetes.io/role/elb" = "1" }
  ])...)

  private_subnet_tags = merge(flatten([
    [for name in var.eks_cluster_names : { "kubernetes.io/cluster/${name}" = "shared" }],
    { "kubernetes.io/role/internal-elb" = "1" }
  ])...)

  tags = var.tags
}
