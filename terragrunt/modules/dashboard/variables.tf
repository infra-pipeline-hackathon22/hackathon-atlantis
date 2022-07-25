variable "eks_cluster_endpoint" {
  type = string
}

variable "eks_cluster_certificate_authority_data" {
  type = string
}

variable "eks_cluster_id" {
  type = string
}

variable "namespace" {
  type        = string
  description = "The namespace in which to install the dashboard"
}

variable "dashboard_admin" {
  type        = string
  description = "The name of the service account that has cluster-admin rights in the dashboard"
}