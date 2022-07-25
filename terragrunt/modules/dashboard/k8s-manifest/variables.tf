variable "namespace" {
    type = string
    description = "The namespace in which to install the dashboard"
}

variable "dashboard_admin" {
    type = string
    description = "The name of the service account that has cluster-admin rights in the dashboard"
}