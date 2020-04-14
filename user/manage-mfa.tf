data "aws_iam_policy_document" "manage-mfa" {
  statement {
    effect = "Allow"

    resources = [
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/$${aws:username}",
    ]

    actions = [
      "iam:DeactivateMFADevice",
      "iam:EnableMFADevice",
      "iam:ResyncMFADevice",
      "iam:ListVirtualMFADevices",
      "iam:ListMFADevices",
    ]
  }

  statement {
    effect = "Allow"

    resources = [
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:mfa/$${aws:username}",
    ]

    actions = [
      "iam:CreateVirtualMFADevice",
    ]
  }

  statement {
    effect = "Allow"

    resources = [
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:mfa/*",
    ]

    actions = [
      "iam:ListVirtualMFADevices",
      "iam:ListMFADevices",
    ]
  }
}

resource "aws_iam_policy" "aws_mfa_self_service" {
  path        = "/"
  description = "Policy for self-managing MFA"

  policy = data.aws_iam_policy_document.manage-mfa.json
}

resource "aws_iam_user_policy_attachment" "mfa-self-service" {
  user = aws_iam_user.this.id
  policy_arn = aws_iam_policy.aws_mfa_self_service.arn
}