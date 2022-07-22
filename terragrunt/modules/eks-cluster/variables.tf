variable "vpc_id" {
  description = "ID of the VPC to install in"
  type        = string
}

variable "vpc_private_subnet_ids" {
  description = "List of private subnet IDs within the VPC to use"
  type        = list(string)
}

variable "cluster_name" {
  description = "Name to give the cluster"
  type        = string
}

variable "eks_version" {
  description = "Version of EKS to use"
  type        = string
}

variable "tags" {
  description = "Tags to apply"
  type        = map(string)
  default     = {}
}
