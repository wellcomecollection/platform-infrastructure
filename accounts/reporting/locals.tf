locals {
  account_ids = {
    platform  = "760097843905"
    reporting = "269807742353"
  }

  account_principals = { for key, value in local.account_ids : key => "arn:aws:iam::${value}:root" }
}
