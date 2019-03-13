data "aws_iam_policy_document" "aws_mfa_self_service_policy" {
  statement {
    effect = "Allow"

    resources = [
      "arn:aws:iam::${var.account-id}:user/$${aws:username}",
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
      "arn:aws:iam::${var.account-id}:mfa/$${aws:username}",
    ]

    actions = [
      "iam:CreateVirtualMFADevice",
      "iam:DeleteVirtualMFADevice",
    ]
  }

  statement {
    effect = "Allow"

    resources = [
      "arn:aws:iam::${var.account-id}:mfa/*",
    ]

    actions = [
      "iam:ListVirtualMFADevices",
      "iam:ListMFADevices",
    ]
  }
}

resource "aws_iam_policy" "aws_mfa_self_service" {
  name        = "${var.team-name}-${var.role}_aws_mfa_self_service"
  path        = "/"
  description = "Policy for MFA self service"

  policy = "${data.aws_iam_policy_document.aws_mfa_self_service_policy.json}"
}

resource "aws_iam_policy_attachment" "aws-mfa-self-service" {
  name       = "${var.team-name}-${var.role}-mfa-self-service"
  groups     = ["${aws_iam_group.group.name}"]
  policy_arn = "${aws_iam_policy.aws_mfa_self_service.arn}"
}