resource "aws_iam_user" "developer" {
  name = "number-zero-developer"
  force_destroy = true
}

resource "aws_iam_user" "admin" {
  name = "the-enabler"
  force_destroy = true
}

module "iam" {
  source = "../iam"

  administrator-trusted-entities = [
    aws_iam_user.admin.arn
  ]
  developer-trusted-entities = [
    aws_iam_user.developer.arn
  ]
}