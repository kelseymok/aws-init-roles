// The myteam-admin role delegates to the myteam-developer role to do many things.
// The following creates permission boundaries around the mteam-developer role such that:
//
// 1. the myteam-developer role can create users IFF the user has a particular permissions boundary
//    https://www.terraform.io/docs/providers/aws/r/iam_user.html#permissions_boundary
// 2. the myteam-developer role can create roles IFF the role has a particular permissions boundary
//    https://www.terraform.io/docs/providers/aws/r/iam_role.html#permissions_boundary
//
// Additionally, the myteam-developer role has PowerUser Access (plus limited IAM permissions
// given (1) and (2)) and the role cannot delete any permissions boundaries.


locals {
  myteam-developer-boundary-name = "myteam-developer-boundary"
  myteam-developer-boundary-arn = "arn:aws:iam::${var.account-id}:policy/${local.myteam-developer-boundary-name}"
}

resource "aws_iam_policy" "myteam-developer-boundary" {
  name = "${local.myteam-developer-boundary-name}"
  policy = "${data.aws_iam_policy_document.myteam-developer-boundary.json}"
}

data "aws_iam_policy_document" "myteam-developer-boundary" {
  statement {
    sid = "CreateOrChangeRoleOnlyWithBoundary"
    actions = [
      "iam:AttachRolePolicy",
      "iam:CreateRole",
      "iam:DeleteRolePolicy",
      "iam:DetachRolePolicy",
      "iam:PutRolePermissionsBoundary",
      "iam:PutRolePolicy",
    ]
    resources = ["*"]

    condition {
      variable = "iam:PermissionsBoundary"
      test = "StringEquals"
      values = ["${aws_iam_policy.myteam-developer-create-role-boundary.arn}"]
    }
  }

  statement {
    sid = "CreateOrChangeUserOnlyWithBoundary"
    actions = [
            "iam:AttachUserPolicy",
            "iam:CreateUser",
            "iam:DeleteUserPermissionsBoundary",
            "iam:DeleteUserPolicy",
            "iam:DetachUserPolicy",
            "iam:PutUserPermissionsBoundary",
            "iam:PutUserPolicy"
    ]
    resources = ["*"]

    condition {
      variable = "iam:PermissionsBoundary"
      test = "StringEquals"
      values = ["${aws_iam_policy.myteam-developer-create-user-boundary.arn}"]
    }
  }

  statement {
    sid = "NoBoundaryPolicyEdit"
    effect = "Deny"
    actions = [
      "iam:CreatePolicyVersion",
      "iam:DeletePolicy",
      "iam:DeletePolicyVersion",
      "iam:SetDefaultPolicyVersion",
    ]
    resources = [
      "${local.myteam-developer-boundary-arn}",
      "${aws_iam_policy.myteam-developer-create-role-boundary.arn}",
      "${aws_iam_policy.myteam-developer-create-user-boundary.arn}",
    ]
  }

  statement {
    sid = "NoBoundaryUserDelete"
    effect = "Deny"
    actions = ["iam:DeleteRolePermissionsBoundary"]
    resources = ["*"]
  }

  statement {
    sid = "DoNotChangeImportantTeamResources"
    effect = "Deny"
    actions = ["iam:*"]
    resources = [
      "arn:aws:iam::${var.account-id}:group/myteam-developer",
      "arn:aws:iam::${var.account-id}:group/myteam-admin",
      "arn:aws:iam::${var.account-id}:group/myteam-readonly",
      "arn:aws:iam::${var.account-id}:role/myteam-developer",
      "arn:aws:iam::${var.account-id}:role/myteam-admin",
      "arn:aws:iam::${var.account-id}:role/myteam-readonly",
    ]
  }

  statement {
    sid = "AllowGetSelf"
    actions = ["iam:GetUser"]
    resources = [
      "arn:aws:iam::${var.account-id}:user/$${aws:username}",
    ]
  }

  statement {
    sid = "AllowPowerUserGenericAccess"
    not_actions = [
      "organizations:*"
    ]
    resources = ["*"]
  }

  statement {
    sid = "AllowPowerUserIAMAccess"
    actions = [
      "organizations:DescribeOrganization"
    ]
    resources = ["*"]
  }
}