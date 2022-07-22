variable "vpc_name" {
  type = string
}

variable "eks_cluster_endpoint" {
  type = string
}

variable "eks_cluster_certificate_authority_data" {
  type = string
}

variable "eks_cluster_id" {
  type = string
}

variable "eks_cluster_version" {
  type = string
}

variable "eks_cluster_oidc_provider" {
  type = string
}

variable "self_managed_node_group_autoscaling_groups" {
  type = list(string)
}

variable "self_managed_node_group_iam_instance_profile_id" {
  type = string
}

variable "tags" {
  description = "Tags to apply"
  type        = map(string)
  default     = {}
}
