resource "aws_iam_user" "developer" {
  name = "number-zero-developer"
  force_destroy = true
}

resource "aws_iam_user" "admin" {
  name = "the-enabler"
  force_destroy = true
}

module "iam" {
  source = "git::ssh://git@github.com/kelseymok/aws-init-roles.git//iam?ref=v1.0.0"

  administrator-trusted-entities = [
    aws_iam_user.admin.arn
  ]
  developer-trusted-entities = [
    aws_iam_user.developer.arn
  ]
}