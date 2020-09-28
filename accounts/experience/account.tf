module "experience_account" {
  source = "../modules/account/aws"

  prefix = "experience"

  principals = [
    local.account_principals["platform"],
    local.account_principals["experience"],
  ]

  infra_bucket_arn = "arn:aws:s3:::wellcomecollection-experience-infra"
}
