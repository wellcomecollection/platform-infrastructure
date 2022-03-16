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

resource "aws_cloudwatch_event_rule" "tasks_stopped" {
  name        = "capture-ecs-task-stopped"
  description = "Capture each task-stopped event in ECS"

  event_pattern = jsonencode({
    source = ["aws.ecs"]

    detail-type = ["ECS Task State Change"]

    detail = {
      lastStatus = ["STOPPED"]
      stopCode   = ["TaskFailedToStart"]
    }
  })
}

resource "aws_cloudwatch_event_target" "tasks_stopped" {
  rule      = aws_cloudwatch_event_rule.tasks_stopped.name
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
