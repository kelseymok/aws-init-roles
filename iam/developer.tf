resource "aws_iam_role" "developer" {
  name                  = var.developer-role-name
  path                  = "/${var.org}/"
  max_session_duration  = local.max_session_duration
  description           = "Developer Role"
  assume_role_policy    = data.aws_iam_policy_document.developer-assume-role-policy.json
  force_detach_policies = true
}

data "aws_iam_policy_document" "developer-assume-role-policy" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type        = "AWS"
      identifiers = var.developer-trusted-entities
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

resource "aws_iam_role_policy_attachment" "power-user" {
  policy_arn = "arn:aws:iam::aws:policy/PowerUserAccess"
  role       = aws_iam_role.developer.name
}

resource "aws_iam_role_policy_attachment" "eks-cluster-policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.developer.name
}

resource "aws_iam_role_policy_attachment" "eks-service-policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.developer.name
}

resource "aws_iam_role_policy_attachment" "systems-manager" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMFullAccess"
  role       = aws_iam_role.developer.name
}

resource "aws_iam_role_policy_attachment" "iam" {
  policy_arn = aws_iam_policy.iam.arn
  role       = aws_iam_role.developer.name
}

resource "aws_iam_policy" "iam" {
  name   = var.developer-role-name
  path   = "/${var.org}/"
  policy = data.aws_iam_policy_document.developer-iam.json
}

data "aws_iam_policy_document" "developer-iam" {
  statement {
    sid     = "DenyEverythingInOrgPath"
    effect  = "Deny"
    actions = ["*"]
    resources = [
      "arn:aws:iam::*:group/${var.org}/*",
      "arn:aws:iam::*:instance-profile/${var.org}/*",
      "arn:aws:iam::*:policy/${var.org}/*",
      "arn:aws:iam::*:role/${var.org}/*",
      "arn:aws:iam::*:user/${var.org}/*",
    ]
  }

  statement {
    sid = "AllowManagingRolesWithBoundary"
    actions = [
      "iam:AttachRolePolicy",
      "iam:CreateRole",
      "iam:DeleteRolePolicy",
      "iam:DetachRolePolicy",
      "iam:PutRolePermissionsBoundary",
      "iam:PutRolePolicy",
    ]
    resources = [
      "*"
    ]
    condition {
      variable = "iam:PermissionsBoundary"
      test     = "ForAnyValue:StringEquals"
      values = [
        aws_iam_policy.boundary.arn
      ]
    }
  }

  statement {
    sid = "AllowManagingRoles"
    actions = [
      "iam:DeleteRole",
      "iam:GetRole",
      "iam:GetRolePolicy",
      "iam:ListAttachedRolePolicies",
      "iam:ListInstanceProfilesForRole",
      "iam:ListRolePolicies",
      "iam:ListRoleTags",
      "iam:ListRoles",
      "iam:PassRole",
      "iam:TagRole",
      "iam:UntagRole",
      "iam:UpdateAssumeRolePolicy",
      "iam:UpdateRole",
      "iam:UpdateRoleDescription",
    ]
    resources = [
      "*"
    ]
  }

  statement {
    sid = "AllowManagingGroups"
    actions = [
      "iam:GetGroup",
      "iam:GetGroupPolicy",
      "iam:DeleteGroup",
      "iam:DetachGroupPolicy",
      "iam:ListAttachedGroupPolicies",
      "iam:ListGroups",
      "iam:ListGroupPolicies",
      "iam:RemoveUserFromGroup"
    ]
    resources = [
      "*"
    ]
  }

  statement {
    sid = "AllowManagingUsersWithBoundary"
    actions = [
      "iam:AttachUserPolicy",
      "iam:CreateUser",
      "iam:DetachUserPolicy",
      "iam:PutUserPermissionsBoundary",
      "iam:PutUserPolicy"
    ]
    resources = [
      "*"
    ]
    condition {
      variable = "iam:PermissionsBoundary"
      test     = "ForAnyValue:StringEquals"
      values = [
        aws_iam_policy.boundary.arn
      ]
    }
  }

  statement {
    sid = "AllowManagingUsers"
    actions = [
      "iam:AddUserToGroup",
      "iam:CreateAccessKey",
      "iam:DeleteAccessKey",
      "iam:DeleteUser",
      "iam:GetUser",
      "iam:GetUserPolicy",
      "iam:ListAccessKeys",
      "iam:ListAttachedUserPolicies",
      "iam:ListGroupsForUser",
      "iam:ListUsers",
      "iam:ListUserPolicies",
      "iam:TagUser",
      "iam:UntagUser",
    ]
    resources = [
      "*"
    ]
  }

  statement {
    sid = "AllowManagingPolicies"
    actions = [
      "iam:CreatePolicy",
      "iam:CreatePolicyVersion",
      "iam:DeletePolicy",
      "iam:DeletePolicyVersion",
      "iam:GetPolicy",
      "iam:GetPolicyVersion",
      "iam:ListEntitiesForPolicy",
      "iam:ListPolicies",
      "iam:ListPolicyVersions",
      "iam:SetDefaultPolicyVersion",
    ]
    resources = [
      "*"
    ]
  }

  statement {
    sid = "AllowManagingInstanceProfiles"
    actions = [
      "iam:AddRoleToInstanceProfile",
      "iam:CreateInstanceProfile",
      "iam:DeleteInstanceProfile",
      "iam:GetInstanceProfile",
      "iam:ListInstanceProfiles",
      "iam:RemoveRoleFromInstanceProfile",
    ]
    resources = [
      "*"
    ]
  }

  statement {
    sid = "FederatedAccessThroughSAML"
    actions = [
      "iam:UpdateSAMLProvider",
      "iam:ListSAMLProviders",
      "iam:GetSAMLProvider",
      "iam:DeleteSAMLProvider",
      "iam:CreateSAMLProvider"
    ]
    resources = [
      "*"
    ]
  }
}

resource "aws_iam_policy" "boundary" {
  name   = "developer-boundary"
  path   = "/${var.org}/"
  policy = data.aws_iam_policy_document.boundary.json
}

data "aws_iam_policy_document" "boundary" {
  statement {
    sid = "AllowFullAccessExceptForAdministratorPermissions"
    not_actions = [
      "iam:*",
      "organizations:*",
      "account:*",
    ]
    resources = ["*"]
  }

  statement {
    sid = "AllowMinimalIamAccess"
    actions = [
      "iam:CreateServiceLinkedRole",
      "iam:DeleteServiceLinkedRole",
      "iam:ListAttachedRolePolicies", // Required for EKS
      "iam:ListRoles",
      "iam:PassRole", // Required for creating service-roles that assume instance roles
      "organizations:DescribeOrganization",
      "account:ListRegions",
    ]
    resources = ["*"]
  }
}
