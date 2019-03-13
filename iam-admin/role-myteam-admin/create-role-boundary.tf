//Should the myteam-developer role need to create roles,
//the roles should not be able to do anything except the below actions

resource "aws_iam_policy" "myteam-developer-create-role-boundary" {
  name = "myteam-developer-create-role-boundary"
  policy = "${data.aws_iam_policy_document.myteam-developer-create-role-boundary.json}"
}

data "aws_iam_policy_document" "myteam-developer-create-role-boundary" {
  statement {
    sid = "AllowReadECR"
    actions = [
      "ecr:DescribeImages",
      "ecr:BatchCheckLayerAvailability",
      "ecr:BatchGetImage",
      "ecr:DescribeRepositories",
      "ecr:GetAuthorizationToken",
      "ecr:GetDownloadUrlForLayer",
      "ecr:GetRepositoryPolicy",
      "ecr:ListImages"
    ]
    resources = ["*"]
  }

  statement {
    sid = "AllowPassRole"
    actions = [
      "iam:PassRole",
    ]

    not_resources = [
      "arn:aws:iam::${var.account-id}:role/myteam-admin",
      "arn:aws:iam::${var.account-id}:role/myteam-developer",
      "arn:aws:iam::${var.account-id}:role/myteam-readonly",
    ]
  }
}