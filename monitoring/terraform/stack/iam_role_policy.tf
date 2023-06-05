# Grafana

resource "aws_iam_role_policy" "ecs_grafana_task_cloudwatch_read" {
  role   = module.task_definition.task_role_name
  policy = data.aws_iam_policy_document.read_cloudwatch_metrics.json
}

data "aws_iam_policy_document" "read_cloudwatch_metrics" {
  statement {
    actions = [
      "cloudwatch:DescribeAlarmHistory",
      "cloudwatch:DescribeAlarms",
      "cloudwatch:DescribeAlarmsForMetric",
      "cloudwatch:GetMetricData",
      "cloudwatch:GetMetricStatistics",
      "cloudwatch:ListMetrics",
    ]

    resources = [
      "*",
    ]
  }
}
