variable "role_arn_override" {
  type = string
  default = ""
  description = "The role to assume.  Leave blank to assume no role and use default aws credentials"
}
