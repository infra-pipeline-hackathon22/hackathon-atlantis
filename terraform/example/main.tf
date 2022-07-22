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

provider "aws" {
  region = "us-west-2"
}
