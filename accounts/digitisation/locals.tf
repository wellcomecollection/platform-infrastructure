locals {
  account_ids = {
    platform     = "760097843905"
    digitisation = "404315009621"
    workflow     = "299497370133"
  }

  account_principals = { for key, value in local.account_ids : key => "arn:aws:iam::${value}:root" }
}
