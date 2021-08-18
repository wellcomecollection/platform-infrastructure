# Grafana

resource "aws_iam_role_policy" "ecs_grafana_task_cloudwatch_read" {
  role   = module.grafana.role_name
  policy = var.allow_cloudwatch_read_metrics_policy_json
}
