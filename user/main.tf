resource "aws_iam_user" "this" {
  name = var.username
  force_destroy = true
}

data "aws_caller_identity" "current" {}