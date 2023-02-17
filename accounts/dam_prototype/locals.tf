locals {
  account_ids = {
    platform      = "760097843905"
    dam_prototype = "241906670800"
  }

  account_principals = { for key, value in local.account_ids : key => "arn:aws:iam::${value}:root" }
}
