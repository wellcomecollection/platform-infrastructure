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
    catalogue    = local.catalogue_account_roles["ci_role_arn"]
    data         = local.data_account_roles["ci_role_arn"]
    digirati     = local.digirati_account_roles["ci_role_arn"]
    digitisation = local.digitisation_account_roles["ci_role_arn"]
    experience   = local.experience_account_roles["ci_role_arn"]
    reporting    = local.reporting_account_roles["ci_role_arn"]
    storage      = local.storage_account_roles["ci_role_arn"]
    workflow     = local.workflow_account_roles["ci_role_arn"]
    identity     = local.identity_account_roles["ci_role_arn"]
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

output "ci_vpc_private_subnets" {
  value = module.ci_vpc.private_subnets
}

output "ci_vpc_public_subnets" {
  value = module.ci_vpc.public_subnets
}

output "ci_vpc_id" {
  value = module.ci_vpc.vpc_id
}

output "developer_vpc_private_subnets" {
  value = module.developer_vpc.private_subnets
}

output "developer_vpc_public_subnets" {
  value = module.developer_vpc.public_subnets
}

output "developer_vpc_id" {
  value = module.developer_vpc.vpc_id
}

output "monitoring_vpc_delta_private_subnets" {
  value = module.monitoring_vpc_delta.private_subnets
}

output "monitoring_vpc_delta_public_subnets" {
  value = module.monitoring_vpc_delta.public_subnets
}

output "monitoring_vpc_delta_id" {
  value = module.monitoring_vpc_delta.vpc_id
}
