terraform {
  source = "${get_parent_terragrunt_dir("root")}/../modules/eks-cluster"
}

include "root" {
  path   = find_in_parent_folders()
  expose = true
}

dependency "vpc" {
  config_path = "../vpc"

  mock_outputs_allowed_terraform_commands = ["validate"]
  mock_outputs = {
    vpc_id = "vpc-00000000"
    private_subnet_ids = [
      "subnet-00000000",
      "subnet-00000001",
      "subnet-00000002",
    ]
  }
}

inputs = {
  vpc_id                 = dependency.vpc.outputs.vpc_id
  vpc_private_subnet_ids = dependency.vpc.outputs.private_subnet_ids

  # Needs to be in the list in the VPC module
  cluster_name = "burner-dev"
  eks_version  = include.root.locals.merged.eks_version
}