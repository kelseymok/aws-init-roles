output "myteam-developer-boundary-arn" {
  value = "${aws_iam_policy.myteam-developer-boundary.arn}"
}

output "myteam-developer-create-role-boundary-arn" {
  value = "${aws_iam_policy.myteam-developer-create-role-boundary.arn}"
}

output "myteam-developer-create-user-boundary-arn" {
  value = "${aws_iam_policy.myteam-developer-create-user-boundary.arn}"
}