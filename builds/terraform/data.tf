data "aws_secretsmanager_secret_version" "buildkite_agent_key" {
  secret_id = "builds/buildkite_agent_key"
}