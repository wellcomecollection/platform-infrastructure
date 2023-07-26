output "admin_role_arn" {
  value = module.catalogue_account.admin_role.arn
}

output "developer_role_arn" {
  value = module.catalogue_account.developer_role.arn
}

output "monitoring_role_arn" {
  value = module.catalogue_account.monitoring_role.arn
}

output "read_only_role_arn" {
  value = module.catalogue_account.read_only_role.arn
}

output "publisher_role_arn" {
  value = module.catalogue_account.publisher_role.arn
}

output "ci_role_arn" {
  value = module.catalogue_account.ci_role.arn
}

output "catalogue_vpc_private_subnets" {
  value = module.catalogue_vpc.private_subnets
}

output "catalogue_vpc_public_subnets" {
  value = module.catalogue_vpc.public_subnets
}

output "catalogue_vpc_id" {
  value = module.catalogue_vpc.vpc_id
}

output "catalogue_vpc_delta_private_subnets" {
  value = module.catalogue_vpc_delta.private_subnets
}

output "catalogue_vpc_delta_public_subnets" {
  value = module.catalogue_vpc_delta.public_subnets
}

output "catalogue_vpc_delta_id" {
  value = module.catalogue_vpc_delta.vpc_id
}
