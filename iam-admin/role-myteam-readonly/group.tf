resource "aws_iam_group" "group" {
  name = "${var.team-name}-${var.role}"
}

resource "aws_iam_group_membership" "group-members" {
  name = "${var.team-name}-${var.role}s"

  users = ["${var.team-members}"]

  group = "${aws_iam_group.group.name}"
}
