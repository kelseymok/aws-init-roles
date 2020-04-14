data "aws_iam_policy_document" "list-iam-users" {
  statement {
    effect = "Allow"

    actions = [
      "iam:GetAccountSummary",
      "iam:ListAccountAliases",
      "iam:ListGroupsForUser",
      "iam:ListUsers",
    ]

    resources = [
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:*",
    ]
  }

  statement {
    actions = ["iam:GetUser"]

    resources = [
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/$${aws:username}",
    ]

    effect = "Allow"
  }
}

resource "aws_iam_policy" "list-iam-users" {
  path        = "/"
  description = "Lets users see the list of users"

  policy = data.aws_iam_policy_document.list-iam-users.json
}


resource "aws_iam_user_policy_attachment" "list-iam-users" {
  user = aws_iam_user.this.id
  policy_arn = aws_iam_policy.list-iam-users.arn
}