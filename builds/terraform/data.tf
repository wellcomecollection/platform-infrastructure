data "aws_secretsmanager_secret_version" "example" {
  secret_id = "builds/buildkite_agent_key"
}