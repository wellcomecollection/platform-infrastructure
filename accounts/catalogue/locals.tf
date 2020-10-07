locals {
  account_ids = {
    platform  = "760097843905"
    catalogue = "756629837203"
  }

  account_principals = { for key, value in local.account_ids : key => "arn:aws:iam::${value}:root" }
}
