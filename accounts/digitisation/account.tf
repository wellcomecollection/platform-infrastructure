module "digitisation_account" {
  source = "../modules/account/aws"

  prefix = "digitisation"

  principals = [
    local.account_principals["platform"],
    local.account_principals["digitisation"],
  ]
}
