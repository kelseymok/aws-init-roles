data "aws_iam_policy_document" "aws_admin_access_policy_document" {
  statement {
    actions = ["iam:*"]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "aws_admin_access_policy" {
  name        = "${var.team-name}-${var.role}-admin-aws-admin-access"
  path        = "/"
  description = "Admin access for roles"

  policy = "${data.aws_iam_policy_document.aws_admin_access_policy_document.json}"
}

resource "aws_iam_policy_attachment" "admin_access_policy_attachment" {
  name       = "${var.team-name}-${var.role}_access_policy_attachment"
  roles      = ["${aws_iam_role.role.name}"]
  policy_arn = "${aws_iam_policy.aws_admin_access_policy.arn}"
}