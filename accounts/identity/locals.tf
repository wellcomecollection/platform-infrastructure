locals {
  account_ids = {
    platform = "760097843905"
    identity = "770700576653"
  }

  account_principals = { for key, value in local.account_ids : key => "arn:aws:iam::${value}:root" }
}
