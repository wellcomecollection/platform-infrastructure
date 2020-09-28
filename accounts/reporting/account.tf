module "reporting_account" {
  source = "../modules/account/aws"

  prefix = "reporting"

  principals = [
    local.account_principals["platform"],
    local.account_principals["reporting"],
  ]

  infra_bucket_arn = "arn:aws:s3:::wellcomecollection-reporting-infra"
}
