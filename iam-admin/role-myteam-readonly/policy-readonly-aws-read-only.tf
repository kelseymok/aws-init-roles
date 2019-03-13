resource "aws_iam_policy_attachment" "readonly_access_read_only_policy_attachment" {
  name       = "${var.team-name}-${var.role}-readonly_access_read_only_policy_attachment"
  roles      = ["${aws_iam_role.role.name}"]
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}