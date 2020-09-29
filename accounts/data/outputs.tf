output "admin_role_arn" {
  value = module.data_account.admin_role_arn
}

output "billing_role_arn" {
  value = module.data_account.billing_role_arn
}

output "developer_role_arn" {
  value = module.data_account.developer_role_arn
}

output "monitoring_role_arn" {
  value = module.data_account.monitoring_role_arn
}

output "read_only_role_arn" {
  value = module.data_account.read_only_role_arn
}

output "publisher_role_arn" {
  value = module.data_account.publisher_role_arn
}

output "ci_role_arn" {
  value = module.data_account.ci_role_arn
}

output "datascience_vpc_private_subnets" {
  value = module.datascience_vpc.private_subnets
}

output "datascience_vpc_public_subnets" {
  value = module.datascience_vpc.public_subnets
}

output "datascience_vpc_id" {
  value = module.datascience_vpc.vpc_id
}
