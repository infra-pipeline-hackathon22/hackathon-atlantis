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

resource "aws_iam_role_policy" "policy" {
  policy = var.role_policy
  role   = aws_iam_role.role.id
}

output "role" {
  value = aws_iam_role.role
}
