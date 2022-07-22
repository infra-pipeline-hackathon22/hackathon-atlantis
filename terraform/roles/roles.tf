terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
  backend "s3" {
    dynamodb_table = "terraform-lock"
    bucket         = "atlantis-hackathon-terraform-state"
    region         = "us-west-2"
    key            = "terraform/roles"
  }
}

variable "role" {
  type = set(object(
  {
    role_arn     = string
    session_name = string
  }))
  default = []
}

provider "aws" {
  region = "us-west-2"
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

data "aws_iam_policy_document" "power_readwrite" {
  statement {
    effect = "Allow"
    actions = [
      "s3:*",
      "ec2:*",
    ]
    resources = ["*"]
  }
}

module "power_readwrite" {
  source = "../modules/eng-role"
  role_name = "power-readwrite"
  role_policy = data.aws_iam_policy_document.power_readwrite.json
  atlantis_role_arn = module.atlantis_role.role.arn
}

output "atlantis" {
  value = module.atlantis_role.role.arn
}

output "test_readwrite" {
  value = module.test_readwrite.role.arn
}

output "power_readwrite" {
  value = module.power_readwrite.role.arn
}
