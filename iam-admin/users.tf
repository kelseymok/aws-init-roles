resource "aws_iam_user" "some-admin-user" {
  name = "some-admin-user@thoughtworks.com"
  force_destroy = true
}

resource "aws_iam_user" "some-developer-user" {
  name = "some-developer-user@thoughtworks.com"
  force_destroy = true
}

resource "aws_iam_user" "some-readonly-user" {
  name = "some-readonly-user@thoughtworks.com"
  force_destroy = true
}