data "aws_iam_policy_document" "aws_list_iam_users_policy" {
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
    actions = ["iam:GetUser"]

    resources = [
      "arn:aws:iam::${var.account-id}:user/$${aws:username}",
    ]

    effect = "Allow"
  }
}

resource "aws_iam_policy" "aws_list_iam_users" {
  name        = "${var.team-name}-${var.role}_aws_list_iam_users"
  path        = "/"
  description = "Let users see the list of users"

  policy = "${data.aws_iam_policy_document.aws_list_iam_users_policy.json}"
}

resource "aws_iam_policy_attachment" "aws-list-iam-users" {
  name       = "${var.team-name}-${var.role}-list-iam-users"
  groups     = ["${aws_iam_group.group.name}"]
  policy_arn = "${aws_iam_policy.aws_list_iam_users.arn}"
}