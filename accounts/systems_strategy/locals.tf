locals {
  account_ids = {
    platform         = "760097843905"
    systems_strategy = "487094370410"
  }

  account_principals = { for key, value in local.account_ids : key => "arn:aws:iam::${value}:root" }
}
