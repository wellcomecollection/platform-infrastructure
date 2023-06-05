data "aws_ssm_parameter" "grafana_admin_password" {
  name = "/aws/reference/secretsmanager/monitoring/grafana_admin_password"
}

locals {
  grafana_anonymous_enabled = true
  grafana_anonymous_role    = "Editor"
  grafana_admin_user        = "admin"
  grafana_admin_password    = data.aws_ssm_parameter.grafana_admin_password.value
}
