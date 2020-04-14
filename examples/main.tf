module "developer-user" {
  source = "git::ssh://git@github.com/kelseymok/aws-init-roles.git//user?ref=v1.2.0"
  username = "number-zero-developer"
}

module "developer-admin" {
  source = "git::ssh://git@github.com/kelseymok/aws-init-roles.git//user?ref=v1.2.0"
  username = "the-enabler"
}

module "iam" {
  source = "git::ssh://git@github.com/kelseymok/aws-init-roles.git//iam?ref=v1.2.0"

  administrator-trusted-entities = [
    module.developer-admin.arn
  ]
  developer-trusted-entities = [
    module.developer-user.arn
  ]

  org = "myorg"
}