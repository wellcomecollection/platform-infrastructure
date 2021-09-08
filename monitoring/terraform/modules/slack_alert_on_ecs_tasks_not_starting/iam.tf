data "aws_iam_policy_document" "allow_describe_services" {
  statement {
    actions = [
      "ecs:DescribeServices",
    ]

    resources = [
      "*",
    ]
  }
}

resource "aws_iam_role_policy" "allow_describe_services" {
  role   = module.alert_on_tasks_not_starting.role_name
  policy = data.aws_iam_policy_document.allow_describe_services.json
}