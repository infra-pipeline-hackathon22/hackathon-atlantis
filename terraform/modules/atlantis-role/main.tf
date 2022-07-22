variable "role" {
  type = object({
    name = string
    namespace = string
    service_accounts = string
  })

  validation {
    condition = length(var.role.service_accounts) > 0
    error_message = "The role.service_accounts value must have at least one element."
  }
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect = "Allow"
    principals {
      identifiers = ["arn:aws:iam::240508968475:oidc-provider/oidc.eks.us-west-2.amazonaws.com/id/87C3022853A908387D967229798BD666"]
      type        = "Federated"
    }
    condition {
      test = "StringEquals"
      values = ["system:serviceaccount:${var.role["namespace"]}:${var.role.service_accounts}"]
      variable = "oidc.eks.us-west-2.amazonaws.com/id/87C3022853A908387D967229798BD666:sub"
    }
  }
}

resource "aws_iam_role" "role" {
  name = var.role.name
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

data "aws_iam_policy_document" "role_policy" {
  statement {
    effect    = "Allow"
    actions   = ["sts:AssumeRole"]
    resources = ["arn:aws:iam::240508968475:role/atlantis/*"]
  }
}

resource "aws_iam_role_policy" "policy" {
  policy = data.aws_iam_policy_document.role_policy.json
  role   = aws_iam_role.role.id
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

resource "aws_iam_role_policy" "terraform_remote_state_policy" {
  policy = data.aws_iam_policy_document.terraform_remote_state.json
  role   = aws_iam_role.role.id
}

data "aws_iam_policy" "readonly" {
  name = "ReadOnlyAccess"
}

resource "aws_iam_role_policy_attachment" "readonly" {
  role       = aws_iam_role.role.name
  policy_arn = data.aws_iam_policy.readonly.arn
}

output "role" {
  value = aws_iam_role.role
}
