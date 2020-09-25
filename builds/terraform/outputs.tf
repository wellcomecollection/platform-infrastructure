output "ci_role_arn" {
  value = data.aws_iam_role.ci_agent.arn
}