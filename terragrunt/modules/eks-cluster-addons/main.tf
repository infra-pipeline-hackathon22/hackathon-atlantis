data "aws_availability_zones" "available" {}

locals {
  azs = slice(data.aws_availability_zones.available.names, 0, 3)
}

# Required for Karpenter to do spot requests
resource "aws_iam_service_linked_role" "spot" {
  aws_service_name = "spot.amazonaws.com"
}

module "eks_blueprints_kubernetes_addons" {
  source = "github.com/aws-ia/terraform-aws-eks-blueprints//modules/kubernetes-addons?ref=v4.0.9"

  eks_cluster_id       = var.eks_cluster_id
  eks_cluster_version  = var.eks_cluster_version
  eks_cluster_endpoint = var.eks_cluster_endpoint
  eks_oidc_provider    = var.eks_cluster_oidc_provider

  auto_scaling_group_names = var.self_managed_node_group_autoscaling_groups

  # EKS Managed Add-ons
  enable_amazon_eks_vpc_cni    = true
  enable_amazon_eks_coredns    = true
  enable_amazon_eks_kube_proxy = true

  # Does not support GitOps management as v4.0.9
  enable_aws_node_termination_handler = true

  #---------------------------------------------------------------
  # ARGO CD ADD-ON
  # https://github.com/aws-ia/terraform-aws-eks-blueprints/blob/main/docs/add-ons/argocd.md
  #---------------------------------------------------------------

  enable_argocd         = true
  argocd_manage_add_ons = true # Indicates that ArgoCD is responsible for managing/deploying Add-ons.
  argocd_applications = {
    addons = {
      path               = "chart"
      repo_url           = "https://github.com/deverton/argocd-demo.git"
      add_on_application = true

      values = {
        karpenterProvisioners = {
          azs = local.azs
          subnetSelectors = {
            "Name" = "${var.vpc_name}-private*"
          }
          tags = var.tags
        }
      }
    }
    workloads = {
      path               = "workloads"
      repo_url           = "https://github.com/deverton/argo-rollouts-demo"
      add_on_application = false
    }
  }
  argocd_helm_config = {
    namespace  = "argocd"
    name       = "argo-cd"
    chart      = "argo-cd"
    repository = "https://argoproj.github.io/argo-helm"
    version    = "4.9.4"
    values     = [templatefile("${path.module}/argocd-values.yaml", {})]
  }

  #---------------------------------------------------------------
  # This enables the infrastructure creation but the Helm
  # chart is managed by ArgoCD
  #---------------------------------------------------------------

  enable_argo_rollouts                = true
  enable_aws_load_balancer_controller = true
  enable_karpenter                    = true
  enable_metrics_server               = true

  karpenter_node_iam_instance_profile = var.self_managed_node_group_iam_instance_profile_id

  tags = var.tags
}
