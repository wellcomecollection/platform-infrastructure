resource "aws_secretsmanager_secret" "grafana_admin_password" {
  name = "monitoring/${var.namespace}/grafana/admin_password"
}

resource "aws_secretsmanager_secret_version" "grafana_admin_password" {
  secret_id     = aws_secretsmanager_secret.grafana_admin_password.id
  secret_string = random_password.grafana_admin_password.result
}

resource "random_password" "grafana_admin_password" {
  length = 20
}

locals {
  # These are configured outside of terraform
  external_grafana_secrets = toset([
    "azure_application_id",
    "azure_client_secret",
    "azure_auth_url",
    "azure_token_url",
  ])
}

resource "aws_secretsmanager_secret" "external_grafana_secrets" {
  for_each = local.external_grafana_secrets
  name     = "monitoring/${var.namespace}/grafana/${each.key}"
}
