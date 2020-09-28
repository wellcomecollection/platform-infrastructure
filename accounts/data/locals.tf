locals {
  account_ids = {
    platform = "760097843905"
    data     = "964279923020"
  }

  account_principals = { for key, value in local.account_ids : key => "arn:aws:iam::${value}:root" }
}
