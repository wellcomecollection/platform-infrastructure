locals {
  account_ids = {
    platform  = "760097843905"
    catalogue = "756629837203"
  }

  aws_region = "eu-west-1"

  secrets_base_arn = "arn:aws:secretsmanager:${local.aws_region}:${local.account_ids["catalogue"]}:secret:"

  account_principals = { for key, value in local.account_ids : key => "arn:aws:iam::${value}:root" }
}
