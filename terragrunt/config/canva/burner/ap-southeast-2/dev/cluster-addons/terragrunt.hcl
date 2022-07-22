terraform {
  source = "${get_parent_terragrunt_dir("root")}/../modules/eks-cluster-addons"
}

include "root" {
  path = find_in_parent_folders()
}

dependency "vpc" {
  config_path = "../vpc"

  mock_outputs_allowed_terraform_commands = ["validate"]
  mock_outputs = {
    vpc_name = "vpc-name"
  }
}

dependency "eks" {
  config_path = "../cluster"

  mock_outputs_allowed_terraform_commands = ["validate"]
  mock_outputs = {
    eks_cluster_id                                  = "eks-00000000"
    eks_cluster_endpoint                            = "https://foo.example.com"
    eks_cluster_certificate_authority_data          = "DEADBEEF"
    eks_cluster_version                             = "1.21"
    eks_cluster_oidc_provider                       = "oidc.eks.us-west-2.amazonaws.com/id/DEADBEEF"
    self_managed_node_group_autoscaling_groups      = tolist([])
    self_managed_node_group_iam_instance_profile_id = "instance-profile"
  }
}

inputs = {
  vpc_name = dependency.vpc.outputs.vpc_name

  eks_cluster_id                                  = dependency.eks.outputs.eks_cluster_id
  eks_cluster_version                             = dependency.eks.outputs.eks_cluster_version
  eks_cluster_endpoint                            = dependency.eks.outputs.eks_cluster_endpoint
  eks_cluster_certificate_authority_data          = dependency.eks.outputs.eks_cluster_certificate_authority_data
  eks_cluster_oidc_provider                       = dependency.eks.outputs.eks_cluster_oidc_provider
  self_managed_node_group_autoscaling_groups      = dependency.eks.outputs.self_managed_node_group_autoscaling_groups
  self_managed_node_group_iam_instance_profile_id = dependency.eks.outputs.self_managed_node_group_iam_instance_profile_id[0]
}