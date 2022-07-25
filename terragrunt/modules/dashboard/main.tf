/*
 * # Kubernetes Dashboard
 *
 * This module adds resources necessary to access Kubernetes dashboard from kubectl proxy
 */

resource "kubernetes_manifest" "namespace_kubernetes_dashboard" {
  manifest = {
    "apiVersion" = "v1"
    "kind"       = "Namespace"
    "metadata" = {
      "name" = var.namespace
    }
  }
}

resource "kubernetes_manifest" "serviceaccount_kube_system_dash_admin" {
  manifest = {
    "apiVersion" = "v1"
    "kind"       = "ServiceAccount"
    "metadata" = {
      "name"      = var.dashboard_admin
      "namespace" = "kube-system"
    }
  }
}

resource "kubernetes_manifest" "clusterrolebinding_dash_admin" {
  manifest = {
    "apiVersion" = "rbac.authorization.k8s.io/v1"
    "kind"       = "ClusterRoleBinding"
    "metadata" = {
      "name" = var.dashboard_admin
    }
    "roleRef" = {
      "apiGroup" = "rbac.authorization.k8s.io"
      "kind"     = "ClusterRole"
      "name"     = "cluster-admin"
    }
    "subjects" = [
      {
        "kind"      = "ServiceAccount"
        "name"      = var.dashboard_admin
        "namespace" = "kube-system"
      },
    ]
  }
}

module "dashboard" {
  source = "./k8s-manifest"

  namespace       = var.namespace
  dashboard_admin = var.dashboard_admin

  depends_on = [
    kubernetes_manifest.namespace_kubernetes_dashboard
  ]
}
