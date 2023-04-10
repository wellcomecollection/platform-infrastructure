module "alert_on_tasks_not_starting" {
  source = "../slack_alert_lambda"

  name        = "alert_on_ecs_tasks_not_starting"
  source_name = "ecs_tasks_cant_start_alert"

  description = "Sends a notification to Slack when ECS tasks are unable to start"

  secrets = [
    "monitoring/critical_slack_webhook",
  ]

  account_name    = var.account_name
  alarm_topic_arn = var.alarm_topic_arn
}

resource "aws_cloudwatch_event_rule" "ecs_task_start_impaired" {
  name        = "capture-ecs-task-start-impaired"
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
  from = aws_lambda_permission.allow_sns_trigger
  to   = aws_lambda_permission.allow_eventbridge_trigger
}

resource "aws_lambda_permission" "allow_eventbridge_trigger" {
  action        = "lambda:InvokeFunction"
  function_name = module.alert_on_tasks_not_starting.arn
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.ecs_task_start_impaired.arn
}

resource "aws_cloudwatch_event_target" "lambda" {
  rule      = aws_cloudwatch_event_rule.ecs_task_start_impaired.name
  target_id = "SendToLambda"
  arn       = module.alert_on_tasks_not_starting.arn
}
