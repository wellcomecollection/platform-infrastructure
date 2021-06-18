output "admin_role_arn" {
  value = module.dam_prototype_account.admin_role_arn
}

output "billing_role_arn" {
  value = module.dam_prototype_account.billing_role_arn
}

output "developer_role_arn" {
  value = module.dam_prototype_account.developer_role_arn
}

output "monitoring_role_arn" {
  value = module.dam_prototype_account.monitoring_role_arn
}

output "read_only_role_arn" {
  value = module.dam_prototype_account.read_only_role_arn
}

output "publisher_role_arn" {
  value = module.dam_prototype_account.publisher_role_arn
}

output "ci_role_arn" {
  value = module.dam_prototype_account.ci_role_arn
}

output "dam_prototype_vpc_private_subnets" {
  value = module.dam_prototype_vpc.private_subnets
}

output "dam_prototype_vpc_cidr_block_private" {
  value = module.dam_prototype_vpc.cidr_block_private
}

output "dam_prototype_vpc_vpc_public_subnets" {
  value = module.dam_prototype_vpc.public_subnets
}

output "dam_prototype_vpc_vpc_id" {
  value = module.dam_prototype_vpc.vpc_id
}