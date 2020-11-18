output "admin_role_arn" {
  value = module.identity_account.admin_role_arn
}

output "billing_role_arn" {
  value = module.identity_account.billing_role_arn
}

output "developer_role_arn" {
  value = module.identity_account.developer_role_arn
}

output "monitoring_role_arn" {
  value = module.identity_account.monitoring_role_arn
}

output "read_only_role_arn" {
  value = module.identity_account.read_only_role_arn
}

output "publisher_role_arn" {
  value = module.identity_account.publisher_role_arn
}

output "ci_role_arn" {
  value = module.identity_account.ci_role_arn
}

output "identity_vpc_private_subnets" {
  value = module.identity_vpc.private_subnets
}

output "identity_cidr_block_private" {
  value = module.identity_vpc.cidr_block_private
}

output "identity_vpc_public_subnets" {
  value = module.identity_vpc.public_subnets
}

output "identity_vpc_id" {
  value = module.identity_vpc.vpc_id
}
