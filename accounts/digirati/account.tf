module "digirati_account" {
  source = "../modules/account/aws"

  prefix = "digirati"

  principals = [
    local.account_principals["platform"],
    local.account_principals["digirati"],
  ]

  sbt_releases_bucket_arn = "arn:aws:s3:::releases.mvn-repo.wellcomecollection.org"
}
