# Client Accounts

## Federation accounts

output "list_roles_sso_id" {
  value = module.account_federation.list_roles_user_id
}

output "list_roles_sso_key" {
  value = module.account_federation.list_roles_user_secret
}

## Assumable roles

output "s3_scala_releases_read_role_arn" {
  value = aws_iam_role.s3_scala_releases_read.arn
}

output "publisher_role_arn" {
  value = module.aws_account.publisher_role_arn
}

output "platform_read_only_role_arn" {
  value = module.aws_account.read_only_role_arn
}

output "ci_role_arn" {
  value = {
    platform : module.aws_account.ci_role_arn,
    experience : module.experience_account.ci_role_arn,
    workflow : module.workflow_account.ci_role_arn,
    data : module.data_account.ci_role_arn,
    catalogue : module.catalogue_account.ci_role_arn,
    storage : module.storage_account.ci_role_arn,
    data : module.data_account.ci_role_arn,
    digirati : module.digirati_account.ci_role_arn,
    reporting : module.reporting_account.ci_role_arn,
    digitisation : module.digitisation_account.ci_role_arn,
  }
}

output "s3_releases_scala_catalogue_client" {
  value = module.s3_releases_scala_catalogue_client.role_arn
}

output "s3_releases_scala_fixtures" {
  value = module.s3_releases_scala_fixtures.role_arn
}

output "s3_releases_scala_json" {
  value = module.s3_releases_scala_json.role_arn
}

output "s3_releases_scala_monitoring" {
  value = module.s3_releases_scala_monitoring.role_arn
}

output "s3_releases_scala_storage" {
  value = module.s3_releases_scala_storage.role_arn
}

output "s3_releases_scala_messaging" {
  value = module.s3_releases_scala_messaging.role_arn
}

output "s3_releases_scala_typesafe" {
  value = module.s3_releases_scala_typesafe.role_arn
}