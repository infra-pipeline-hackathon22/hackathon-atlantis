variable "vpc_name" {
  type        = string
  description = "Name of the VPC"
}

variable "vpc_ipv4_cidr" {
  type        = string
  description = "IPv4 CIDR of the VPC"
}

variable "eks_cluster_names" {
  type        = list(string)
  default     = []
  description = "List of EKS cluster names to tag subnets with for Kubernetes to use"
}

variable "tags" {
  description = "Tags to apply"
  type        = map(string)
  default     = {}
}
