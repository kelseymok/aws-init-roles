data "aws_iam_policy_document" "access_role_policy" {
  statement {
    effect = "Allow"

    actions = [
      "sts:AssumeRole",
    ]

    condition {
      variable = "aws:MultiFactorAuthPresent"
      test     = "Bool"
      values   = ["true"]
    }

    condition {
      variable = "aws:MultiFactorAuthAge"
      test     = "NumericLessThanEquals"
      values   = ["${12 * 60 * 60}"]
    }

    principals {
      type = "AWS"

      identifiers = [
        "arn:aws:iam::${var.account-id}:root",
      ]
    }
  }
}
