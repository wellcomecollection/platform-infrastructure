module "systems_strategy_account" {
  source = "../modules/account/aws"

  prefix = "systems_strategy"

  principals = [
    local.account_principals["platform"],
    local.account_principals["systems_strategy"],
  ]
}
