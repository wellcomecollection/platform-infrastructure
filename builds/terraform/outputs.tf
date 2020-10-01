output "ci_role_arn" {
  value = data.aws_iam_role.ci_agent.arn
}

output "ci_role_name" {
  value = local.ci_agent_role_name
}
