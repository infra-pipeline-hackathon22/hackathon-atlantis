terraform {
  source = "${get_parent_terragrunt_dir("root")}/../modules/outputs"
}

include "root" {
  path = find_in_parent_folders()
}

dependency "eks" {
  config_path = "../cluster"

  mock_outputs_allowed_terraform_commands = ["validate"]
  mock_outputs = {
    eks_cluster_id                           = "eks-00000000"
    eks_cluster_endpoint                     = "https://foo.example.com"
    eks_cluster_certificate_authority_data   = "DEADBEEF"
    eks_eks_cluster_self_managed_node_groups = ""
  }
}

dependencies {
  paths = ["../cluster", "../cluster-addons"]
}

inputs = {
  eks_cluster_id                         = dependency.eks.outputs.eks_cluster_id
  eks_cluster_endpoint                   = dependency.eks.outputs.eks_cluster_endpoint
  eks_cluster_certificate_authority_data = dependency.eks.outputs.eks_cluster_certificate_authority_data
}