data "aws_iam_policy_document" "assume_role_group_policy_document" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]

    effect = "Allow"

    resources = [
      "${aws_iam_role.role.arn}",
    ]
  }
}

resource "aws_iam_group_policy" "assume_role_access_group_policy" {
  name  = "readonly_access_group_policy"
  group = "${aws_iam_group.group.id}"

  policy = "${data.aws_iam_policy_document.assume_role_group_policy_document.json}"
}
