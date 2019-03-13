module "myteam-readonly" {
  source = "role-myteam-readonly"

  account-id = "${data.aws_caller_identity.current.account_id}"
  team-name = "myteam"
  role = "readonly"
  team-members = [
    "some-readonly-user@thoughtworks.com",
  ]
}
