output "admin_role_arn" {
  value = module.experience_account.admin_role.arn
}

output "developer_role_arn" {
  value = module.experience_account.developer_role.arn
}

output "monitoring_role_arn" {
  value = module.experience_account.monitoring_role.arn
}

output "read_only_role_arn" {
  value = module.experience_account.read_only_role.arn
}

output "publisher_role_arn" {
  value = module.experience_account.publisher_role.arn
}

output "ci_role_arn" {
  value = module.experience_account.ci_role.arn
}

output "experience_vpc_private_subnets" {
  value = module.experience_vpc.private_subnets
}

output "experience_vpc_public_subnets" {
  value = module.experience_vpc.public_subnets
}

output "experience_vpc_id" {
  value = module.experience_vpc.vpc_id
}
