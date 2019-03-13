resource "aws_iam_role" "role" {
  name = "${var.team-name}-${var.role}"

  assume_role_policy = "${data.aws_iam_policy_document.access_role_policy.json}"
}
