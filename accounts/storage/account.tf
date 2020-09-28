module "storage_account" {
  source = "../modules/account/aws"

  prefix = "storage"

  principals = [
    local.account_principals["platform"],
    local.account_principals["storage"],
  ]

  infra_bucket_arn = "arn:aws:s3:::wellcomecollection-storage-infra"
}
