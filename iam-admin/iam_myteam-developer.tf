module "myteam-developer" {
  source = "role-myteam-developer"

  account-id = "${data.aws_caller_identity.current.account_id}"
  team-name = "myteam"
  role = "developer"
  team-members = [
    "${aws_iam_user.some-developer-user.name}"
  ]
}
