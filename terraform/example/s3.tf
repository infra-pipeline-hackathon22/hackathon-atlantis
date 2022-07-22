terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }
  backend "s3" {
    dynamodb_table = "terraform-lock"
    bucket         = "atlantis-hackathon-terraform-state"
    region         = "us-west-2"
    key            = "terraform/example"
  }
  required_version = "~> 1.0"
}

variable "role_arn_override" {
  type = string
  default = ""
  description = "The role to assume.  Leave blank to assume no role and use default aws credentials"
}

provider "aws" {
  region = "us-west-2"
}


data "aws_partition" "current" {}
data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

locals {
  partition  = data.aws_partition.current.partition
  region     = data.aws_region.current.name
  account_id = data.aws_caller_identity.current.account_id
}

resource "aws_s3_bucket" "test_bucket" {
  bucket_prefix = "atlantis-test-"
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  versioning {
    enabled = true
  }

  lifecycle_rule {
    id      = "transition-objects-to-glacier"
    enabled = true
    transition {
      days          = 365
      storage_class = "GLACIER"
    }
  }
}
