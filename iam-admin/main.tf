provider "aws" {
  version = "~> 1.3"
  region = "eu-central-1"
}

terraform {
  backend "s3" {
    key = "myteam_iam-admin"
    region = "eu-central-1"
    bucket = "myteam-terraform-state"
    dynamodb_table = "TerraformLocks"
  }
}

locals {
  team_name = "myteam"
}

data "aws_caller_identity" "current" {}