output "admin_role_arn" {
  value = module.storage_account.admin_role_arn
}

output "developer_role_arn" {
  value = module.storage_account.developer_role_arn
}

output "monitoring_role_arn" {
  value = module.storage_account.monitoring_role_arn
}

output "read_only_role_arn" {
  value = module.storage_account.read_only_role_arn
}

output "publisher_role_arn" {
  value = module.storage_account.publisher_role_arn
}

output "ci_role_arn" {
  value = module.storage_account.ci_role_arn
}

output "storage_vpc_private_subnets" {
  value = module.storage_vpc.private_subnets
}

output "storage_vpc_public_subnets" {
  value = module.storage_vpc.public_subnets
}

output "storage_vpc_id" {
  value = module.storage_vpc.vpc_id
}
