# This is a policy which lets you self-service your own access keys.
# The only condition is that you have a MFA enabled session
data "aws_iam_policy_document" "aws_access_key_self_service_policy" {
  statement {
    actions = [
      "iam:CreateAccessKey",
      "iam:DeleteAccessKey",
      "iam:ListAccessKeys",
      "iam:UpdateAccessKey",
      "iam:GetAccessKeyLastUsed"
    ]

    effect = "Allow"

    condition {
      variable = "aws:MultiFactorAuthPresent"
      test     = "Bool"
      values   = ["true"]
    }

    condition {
      variable = "aws:MultiFactorAuthAge"
      test     = "NumericLessThanEquals"
      values   = ["${12 * 60 * 60}"]
    }

    resources = [
      "arn:aws:iam::${var.account-id}:user/$${aws:username}",
    ]
  }
}

resource "aws_iam_policy" "aws_access_key_self_service" {
  name        = "${var.team-name}-${var.role}_aws_access_key_self_service"
  path        = "/"
  description = "Policy for access key self service"

  policy = "${data.aws_iam_policy_document.aws_access_key_self_service_policy.json}"
}

resource "aws_iam_policy_attachment" "aws-access-key-self-service" {
  name       = "${var.team-name}-${var.role}-access-key-self-service"
  groups     = ["${aws_iam_group.group.name}"]
  policy_arn = "${aws_iam_policy.aws_access_key_self_service.arn}"
}
