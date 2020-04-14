data "aws_iam_policy_document" "access-key-self-service" {
  statement {
    actions = [
      "iam:CreateAccessKey",
      "iam:DeleteAccessKey",
      "iam:ListAccessKeys",
      "iam:UpdateAccessKey",
    ]

    effect = "Allow"

    condition {
      test     = "Bool"
      variable = "aws:MultiFactorAuthPresent"
      values   = ["true"]
    }

    condition {
      test     = "NumericLessThan"
      variable = "aws:MultiFactorAuthAge"
      values   = [local.max_session_duration]
    }

    resources = [
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/$${aws:username}",
    ]
  }
}

resource "aws_iam_policy" "aws_access_key_self_service" {
  path        = "/"
  description = "Policy for access key self service"

  policy = data.aws_iam_policy_document.access-key-self-service.json
}

resource "aws_iam_user_policy_attachment" "access-key-self-service" {
  user = aws_iam_user.this.id
  policy_arn = aws_iam_policy.aws_access_key_self_service.arn
}