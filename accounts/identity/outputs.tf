output "admin_role_arn" {
  value = module.identity_account.admin_role.arn
}

output "developer_role_arn" {
  value = module.identity_account.developer_role.arn
}

output "monitoring_role_arn" {
  value = module.identity_account.monitoring_role.arn
}

output "read_only_role_arn" {
  value = module.identity_account.read_only_role.arn
}

output "publisher_role_arn" {
  value = module.identity_account.publisher_role.arn
}

output "ci_role_arn" {
  value = module.identity_account.ci_role.arn
}

output "identity_prod_vpc_private_subnets" {
  value = module.identity_vpc_prod.private_subnets
}

output "identity_prod_cidr_block_private" {
  value = module.identity_vpc_prod.cidr_block_private
}

output "identity_prod_vpc_public_subnets" {
  value = module.identity_vpc_prod.public_subnets
}

output "identity_prod_vpc_id" {
  value = module.identity_vpc_prod.vpc_id
}

output "identity_stage_vpc_private_subnets" {
  value = module.identity_vpc_stage.private_subnets
}

output "identity_stage_cidr_block_private" {
  value = module.identity_vpc_stage.cidr_block_private
}

output "identity_stage_vpc_public_subnets" {
  value = module.identity_vpc_stage.public_subnets
}

output "identity_stage_vpc_id" {
  value = module.identity_vpc_stage.vpc_id
}
