module "digirati_account" {
  source = "../modules/account/aws"

  prefix = "digirati"

  principals = [
    local.account_principals["platform"],
    local.account_principals["digirati"],
  ]
}
