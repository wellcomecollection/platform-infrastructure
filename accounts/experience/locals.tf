locals {
  account_ids = {
    platform   = "760097843905"
    experience = "130871440101"
  }

  aws_region = "eu-west-1"

  account_principals = { for key, value in local.account_ids : key => "arn:aws:iam::${value}:root" }
}
