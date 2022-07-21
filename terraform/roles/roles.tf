terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

module "atlantis_role" {
  source = "../modules/atlantis-role"

  role = {
    name = "atlantis"
    namespace = "atlantis"
    service_accounts = "atlantis"
  }
}

data "aws_iam_policy_document" "test_readwrite" {
  statement {
    effect = "Allow"
    actions = [
      "s3:*"
    ]
    resources = ["*"]
  }
}

module "test_readwrite" {
  source = "../modules/eng-role"
  role_name = "test-readwrite"
  role_policy = data.aws_iam_policy_document.test_readwrite.json
  atlantis_role_arn = module.atlantis_role.role.arn
}

output "atlantis" {
  value = module.atlantis_role.role.arn
}

output "test_readwrite" {
  value = module.test_readwrite.role.arn
}
