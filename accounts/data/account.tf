module "data_account" {
  source = "../modules/account/aws"

  prefix = "data"

  principals = [
    local.account_principals["platform"],
    local.account_principals["data"],
  ]

  infra_bucket_arn = "arn:aws:s3:::wellcomecollection-datascience-infra"
}
