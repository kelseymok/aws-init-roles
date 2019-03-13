module "myteam-admin" {
  source = "role-myteam-admin"

  account-id = "${data.aws_caller_identity.current.account_id}"
  team-name = "myteam"
  role = "admin"
  team-members = [
    "${aws_iam_user.some-admin-user.name}"
  ]
}
