terraform {
  source = "${get_parent_terragrunt_dir("root")}/../modules/vpc"
}

include "root" {
  path   = find_in_parent_folders()
  expose = true
}

inputs = {
  aws_region       = include.root.locals.merged.aws_region
  aws_account_name = include.root.locals.merged.account_name

  vpc_name      = join("-", [include.root.locals.merged.account_name, include.root.locals.merged.flavour])
  vpc_ipv4_cidr = "10.42.0.0/16"

  eks_cluster_names = ["burner-dev"]
}
