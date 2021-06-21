module "identity_account" {
  source = "../modules/account/aws"

  prefix = "identity"

  principals = [
    local.account_principals["platform"],
    local.account_principals["identity"],
  ]
}
