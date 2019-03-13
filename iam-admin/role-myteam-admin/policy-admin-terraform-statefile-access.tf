data "aws_kms_key" "key" {
  key_id = "some-kms-key"
}

data "aws_iam_policy_document" "terraform-init" {

  statement {
    actions = [
      "s3:ListBucket",
      "s3:CreateBucket",
      "s3:GetBucketVersioning"
    ]

    resources = [
      "arn:aws:s3:::myteam-terraform-state-bucket",
    ]
  }

  statement {
    actions = [
      "s3:GetObject",
      "s3:PutObject"
    ]

    resources = [
      "arn:aws:s3:::myteam-terraform-state-bucket/*"
    ]
  }

  statement {
    actions = [
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:DeleteItem",
      "dynamodb:DescribeTable",
      "dynamodb:CreateTable"
    ]

    resources = [
      "arn:aws:dynamodb:*:*:table/MyTeamTerraformLocksTable"
    ]
  }

  statement {
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey"
    ]

    resources = [
      "${data.aws_kms_key.key.arn}"
    ]
  }
}

resource "aws_iam_policy" "terraform-init" {
  name        = "${var.team-name}-${var.role}-terraform-init"
  path        = "/"
  description = "Terraform init policy for ${var.team-name}-${var.role}"

  policy = "${data.aws_iam_policy_document.terraform-init.json}"
}

resource "aws_iam_policy_attachment" "terraform-init" {
  name       = "${var.team-name}-${var.role}_terraform_init_access_policy_attachment"
  roles      = ["${aws_iam_role.role.name}"]
  policy_arn = "${aws_iam_policy.terraform-init.arn}"
}
