output "permissions-boundary-arn" {
  value = aws_iam_policy.boundary.arn
}

output "developer-role-arn" {
  value = aws_iam_role.developer.arn
}

output "administrator-role-arn" {
  value = aws_iam_role.administrator.arn
}