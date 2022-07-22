output "configure_kubectl" {
  description = "Configure kubectl: make sure you're logged in with the correct AWS profile and run the following command to update your kubeconfig"
  value       = module.eks_blueprints.configure_kubectl
}

output "eks_cluster_endpoint" {
  description = "Cluster endpoint"
  value       = module.eks_blueprints.eks_cluster_endpoint
}

output "eks_cluster_certificate_authority_data" {
  description = "Cluster endpoint CA certificate"
  value       = module.eks_blueprints.eks_cluster_certificate_authority_data
}

output "eks_cluster_id" {
  description = "Cluster ID"
  value       = module.eks_blueprints.eks_cluster_id
}

output "eks_cluster_oidc_provider" {
  description = "Cluster OIDC Provider"
  value       = module.eks_blueprints.oidc_provider
}

output "eks_cluster_version" {
  description = "Cluster API Version"
  value       = module.eks_blueprints.eks_cluster_version
}

output "self_managed_node_group_autoscaling_groups" {
  value = module.eks_blueprints.self_managed_node_group_autoscaling_groups
}

output "self_managed_node_group_iam_instance_profile_id" {
  value = module.eks_blueprints.self_managed_node_group_iam_instance_profile_id
}
