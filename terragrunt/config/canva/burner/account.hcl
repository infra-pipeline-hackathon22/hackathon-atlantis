locals {
  # Account name/alias
  account_name = "burner"

  # AWS Account ID
  account_id = "${get_aws_account_id()}"

  # Region for "global" resources
  global_region = "ap-southeast-2"
}