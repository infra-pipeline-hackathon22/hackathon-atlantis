output "argocd_admin_password" {
  value = nonsensitive(data.kubernetes_secret.argocd.data.password)
}

output "argocd_endpoint" {
  value = "https://${data.aws_lb.argocd.dns_name}"
}


output "argo_rollouts_endpoint" {
  value = "http://${data.aws_lb.argo_rollouts.dns_name}"
}
