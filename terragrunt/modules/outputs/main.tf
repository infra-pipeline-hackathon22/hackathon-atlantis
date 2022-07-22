data "kubernetes_secret" "argocd" {
  metadata {
    name      = "argocd-initial-admin-secret"
    namespace = "argocd"
  }
}

data "aws_lb" "argocd" {
  tags = {
    "service.k8s.aws/stack"    = "argocd/argo-cd-argocd-external"
    "service.k8s.aws/resource" = "LoadBalancer"
    "elbv2.k8s.aws/cluster"    = var.eks_cluster_id
  }
}

data "aws_lb" "argo_rollouts" {
  tags = {
    "service.k8s.aws/stack"    = "argo-rollouts/argo-rollouts-dashboard"
    "service.k8s.aws/resource" = "LoadBalancer"
    "elbv2.k8s.aws/cluster"    = var.eks_cluster_id
  }
}
