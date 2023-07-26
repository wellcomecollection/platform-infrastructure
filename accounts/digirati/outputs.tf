output "admin_role_arn" {
  value = module.digirati_account.admin_role.arn
}

output "developer_role_arn" {
  value = module.digirati_account.developer_role.arn
}

output "monitoring_role_arn" {
  value = module.digirati_account.monitoring_role.arn
}

output "read_only_role_arn" {
  value = module.digirati_account.read_only_role.arn
}

output "publisher_role_arn" {
  value = module.digirati_account.publisher_role.arn
}

output "ci_role_arn" {
  value = module.digirati_account.ci_role.arn
}

output "digirati_vpc_private_subnets" {
  value = module.digirati_vpc.private_subnets
}

output "digirati_cidr_block_private" {
  value = module.digirati_vpc.cidr_block_private
}

output "digirati_vpc_public_subnets" {
  value = module.digirati_vpc.public_subnets
}

output "digirati_vpc_id" {
  value = module.digirati_vpc.vpc_id
}

output "moh_vpc_private_subnets" {
  value = module.moh_vpc.private_subnets
}

output "moh_cidr_block_private" {
  value = module.moh_vpc.cidr_block_private
}

output "moh_vpc_public_subnets" {
  value = module.moh_vpc.public_subnets
}

output "moh_vpc_id" {
  value = module.moh_vpc.vpc_id
}