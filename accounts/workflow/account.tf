module "workflow_account" {
  source = "../modules/account/aws"

  prefix = "workflow"

  principals = [
    local.account_principals["platform"],
    local.account_principals["workflow"],
  ]

  infra_bucket_arn = "arn:aws:s3:::wellcomecollection-workflow-infra"
}
