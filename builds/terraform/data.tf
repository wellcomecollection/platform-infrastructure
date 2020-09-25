data "aws_ssm_parameter" "non_critical_slack_webhook" {
  name = "/aws/reference/secretsmanager/builds/non_critical_slack_webhook"
}

data "aws_secretsmanager_secret_version" "example" {
  secret_id = "builds/buildkite_agent_key"
}