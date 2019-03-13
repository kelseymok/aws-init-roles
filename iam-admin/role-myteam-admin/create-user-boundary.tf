//Should the myteam-developer role need to create users,
//the users should not be able to do anything except self-service actions

resource "aws_iam_policy" "myteam-developer-create-user-boundary" {
  name = "myteam-developer-create-user-boundary"
  policy = "${data.aws_iam_policy_document.myteam-developer-create-user-boundary.json}"
}

data "aws_iam_policy_document" "myteam-developer-create-user-boundary" {
  statement {
    effect = "Allow"

    actions = [
      "iam:GetAccountSummary",
      "iam:ListAccountAliases",
      "iam:ListGroupsForUser",
      "iam:ListUsers",
    ]

    resources = [
      "arn:aws:iam::${var.account-id}:*",
    ]
  }

  statement {
    actions = [
      "iam:GetUser",
      "iam:CreateAccessKey",
      "iam:DeleteAccessKey",
      "iam:ListAccessKeys",
      "iam:UpdateAccessKey",
      "iam:GetAccessKeyLastUsed",
      "iam:DeactivateMFADevice",
      "iam:EnableMFADevice",
      "iam:ResyncMFADevice",
      "iam:ListVirtualMFADevices",
      "iam:ListMFADevices",
      "iam:CreateVirtualMFADevice",
      "iam:DeleteVirtualMFADevice",
    ]
    resources = [
      "arn:aws:iam::${var.account-id}:user/$${aws:username}"
    ]
  }

  statement {
    actions = [
      "iam:ListVirtualMFADevices",
      "iam:ListMFADevices",
    ]

    resources = [
      "arn:aws:iam::${var.account-id}:mfa/*",
    ]
  }
}