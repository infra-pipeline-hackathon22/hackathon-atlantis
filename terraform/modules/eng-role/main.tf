variable "role_name" {
  type = string
}

variable "role_policy" {
  type = string
}

variable "atlantis_role_arn" {
  type = string
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    effect = "Allow"
    principals {
      identifiers = [var.atlantis_role_arn]
      type        = "AWS"
    }
  }
}

resource "aws_iam_role" "role" {
  name = var.role_name
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
  path = "/atlantis/"
}

data "aws_iam_policy_document" "terraform_remote_state" {
  statement {
    effect    = "Allow"
    actions   = ["s3:ListBucket"]
    resources = ["arn:aws:s3:::atlantis-hackathon-terraform-state"]
  }
  statement {
    effect    = "Allow"
    actions   = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
      "s3:GetObjectVersion",
      "s3:GetObjectVersionAcl",
      "s3:DeleteObjectVersion",
    ]
    resources = ["arn:aws:s3:::atlantis-hackathon-terraform-state/*"]
  }
  statement {
    effect    = "Allow"
    actions   = [
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:DeleteItem"
    ]
    resources = ["arn:aws:dynamodb:*:*:table/terraform-lock"]
  }
}

resource "aws_iam_role_policy" "policy" {
  policy = data.aws_iam_policy_document.terraform_remote_state.json
  role   = aws_iam_role.role.id
}

resource "aws_iam_role_policy" "terraform_remote_state_policy" {
  policy = var.role_policy
  role   = aws_iam_role.role.id
}

output "role" {
  value = aws_iam_role.role
}
