skip                          = true
terragrunt_version_constraint = ">= 0.32"

locals {
  merged = merge(
    read_terragrunt_config(find_in_parent_folders("flavour.hcl")).locals,
    read_terragrunt_config(find_in_parent_folders("region.hcl")).locals,
    read_terragrunt_config(find_in_parent_folders("account.hcl")).locals,
    read_terragrunt_config(find_in_parent_folders("organisation.hcl")).locals,
  )

  # These should not be overridden at lower levels
  account_vars  = read_terragrunt_config(find_in_parent_folders("account.hcl")).locals
  account_name  = local.account_vars.account_name
  account_id    = local.account_vars.account_id
  global_region = local.account_vars.global_region
}

# Generate an AWS provider block
generate "provider" {
  path      = "_tg_provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "aws" {
  region = "${local.global_region}"
  # Only these AWS Account IDs may be operated on by this template
  allowed_account_ids = ["${local.account_id}"]
}
EOF
}

generate "versions" {
  path      = "_tg_versions_override.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
    terraform {
      required_version = ">= 1.0.0"
      required_providers {
        aws = {
          source  = "hashicorp/aws"
          version = ">= 4.15"
        }
        cloudinit = {
          source  = "hashicorp/cloudinit"
          version = ">= 2.2"
        }
        helm = {
          source  = "hashicorp/helm"
          version = ">= 2.5"
        }
        http = {
          source  = "hashicorp/http"
          version = ">= 2.1"
        }
        kubectl = {
          source  = "gavinbunney/kubectl"
          version = ">= 1.14"
        }
        kubernetes = {
          source  = "hashicorp/kubernetes"
          version = ">= 2.11"
        }
        local = {
          source  = "hashicorp/local"
          version = ">= 2.2"
        }
        null = {
          source  = "hashicorp/null"
          version = ">= 3.1"
        }
        time = {
          source  = "hashicorp/time"
          version = ">= 0.7"
        }
        tls = {
          source  = "hashicorp/tls"
          version = ">= 3.4"
        }
      }
    }
EOF
}

remote_state {
  backend = "s3"

  config = {
    encrypt        = true
    bucket         = "${local.account_id}-${local.account_name}-tg-state"
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = local.global_region
    dynamodb_table = "${local.account_id}-${local.account_name}-tg-state-locks"
  }

  generate = {
    path      = "_tg_backend.tf"
    if_exists = "overwrite_terragrunt"
  }
}
