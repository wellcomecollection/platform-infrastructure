locals {
  dds_principal_arn = "arn:aws:iam::${local.account_ids["digirati"]}:user/dlcs-dds"

  account_ids = {
    platform = "760097843905"
    digirati = "653428163053"
  }

  account_principals = { for key, value in local.account_ids : key => "arn:aws:iam::${value}:root" }
}
