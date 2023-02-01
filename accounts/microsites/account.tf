module "microsites_account" {
  source = "../modules/account/aws"

  prefix = "microsites"

  principals = [
    local.account_principals["platform"],
    local.account_principals["microsites"],
  ]
}
