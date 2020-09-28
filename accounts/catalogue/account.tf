module "catalogue_account" {
  source = "../modules/account/aws"

  prefix = "catalogue"

  principals = [
    local.account_principals["platform"],
    local.account_principals["catalogue"],
  ]

  infra_bucket_arn = "arn:aws:s3:::wellcomecollection-catalogue-infra-delta"
}
