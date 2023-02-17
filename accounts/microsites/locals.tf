locals {
  account_ids = {
    platform   = "760097843905"
    microsites = "782179017633"
  }

  account_principals = { for key, value in local.account_ids : key => "arn:aws:iam::${value}:root" }
}
