module "alert_on_tasks_not_starting" {
  source = "../slack_alert_lambda"

  name        = "alert_on_ecs_tasks_not_starting"
  source_name = "ecs_tasks_cant_start_alert"

  description = "Sends a notification to Slack when ECS tasks are unable to start"
  topic_name  = "ecs_tasks_cant_start"

  secrets = [
    "monitoring/critical_slack_webhook",
  ]

  account_name    = var.account_name
  alarm_topic_arn = var.alarm_topic_arn
}

moved {
  from = aws_cloudwatch_event_rule.tasks_stopped
  to   = aws_cloudwatch_event_rule.ecs_task_start_impaired
}

resource "aws_cloudwatch_event_rule" "ecs_task_start_impaired" {
  name        = "capture-ecs-task-stopped"
  description = "Capture each 'service task start impaired' event in ECS"

  # This event is sent when the service is unable to consistently start
  # tasks effectively.
  # See https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs_cwe_events.html#ecs_service_events_warn_type
  event_pattern = jsonencode({
    source = ["aws.ecs"]

    detail = {
      eventName = ["SERVICE_TASK_START_IMPAIRED"]
    }
  })
}

moved {
  from = aws_cloudwatch_event_target.tasks_stopped
  to   = aws_cloudwatch_event_target.ecs_task_start_impaired
}

resource "aws_cloudwatch_event_target" "ecs_task_start_impaired" {
  rule      = aws_cloudwatch_event_rule.ecs_task_start_impaired.name
  target_id = "SendToSNS"
  arn       = module.alert_on_tasks_not_starting.trigger_topic_arn
}

resource "aws_sns_topic_policy" "default" {
  arn    = module.alert_on_tasks_not_starting.trigger_topic_arn
  policy = data.aws_iam_policy_document.sns_topic_policy.json
}

data "aws_iam_policy_document" "sns_topic_policy" {
  statement {
    effect  = "Allow"
    actions = ["SNS:Publish"]

    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }

    resources = [module.alert_on_tasks_not_starting.trigger_topic_arn]
  }
}
