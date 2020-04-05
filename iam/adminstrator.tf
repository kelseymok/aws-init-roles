data "aws_iam_policy_document" "administrator" {
  statement {
    sid = "AllowFullAccessForIAMAccountsAndOrgs"
    actions = [
      "iam:*",
      "organizations:*",
      "account:*",
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "administrator" {
  name   = "administrator"
  path   = "/${var.org}/"
  policy = data.aws_iam_policy_document.administrator.json
}

resource "aws_iam_role" "administrator" {
  name = "administrator"

  assume_role_policy = data.aws_iam_policy_document.administrator-assume-role-policy
}

data "aws_iam_policy_document" "administrator-assume-role-policy" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type        = "AWS"
      identifiers = var.administrator-trusted-entities
    }

    condition {
      variable = "aws:MultiFactorAuthPresent"
      test     = "Bool"
      values   = ["true"]
    }

    condition {
      variable = "aws:MultiFactorAuthAge"
      test     = "NumericLessThanEquals"
      values   = [local.max_session_duration]
    }
  }
}