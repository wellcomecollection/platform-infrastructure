module "dam_prototype_account" {
  source = "../modules/account/aws"

  prefix = "dam_prototype"

  principals = [
    local.account_principals["platform"],
    local.account_principals["dam_prototype"],
  ]
}
