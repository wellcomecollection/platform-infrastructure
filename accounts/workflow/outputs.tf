output "admin_role_arn" {
  value = module.workflow_account.admin_role.arn
}

output "developer_role_arn" {
  value = module.workflow_account.developer_role.arn
}

output "monitoring_role_arn" {
  value = module.workflow_account.monitoring_role.arn
}

output "read_only_role_arn" {
  value = module.workflow_account.read_only_role.arn
}

output "publisher_role_arn" {
  value = module.workflow_account.publisher_role.arn
}

output "ci_role_arn" {
  value = module.workflow_account.ci_role.arn
}

output "workflow_support_role_arn" {
  value = module.workflow_support_role.arn
}
