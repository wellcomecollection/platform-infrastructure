resource "aws_sns_topic" "chatbot_events" {
  name = "${var.configuration_name}-chatbot-events"
}

resource "aws_cloudwatch_event_rule" "cloudwatch_alarms" {
  name        = "${var.configuration_name}-cloudwatch-alarms"
  description = "Rule to send CloudWatch Alarms to Chatbot"

  event_pattern = jsonencode({
    source      = ["aws.cloudwatch"]
    detail-type = ["CloudWatch Alarm State Change"]
    resources   = ["arn:aws:cloudwatch:eu-west-1:760097843905:alarm:rkenny-deleteme-test"]
  })
}

resource "aws_cloudwatch_event_target" "sns" {
  rule = aws_cloudwatch_event_rule.cloudwatch_alarms.name
  arn  = aws_sns_topic.chatbot_events.arn
}

resource "awscc_chatbot_slack_channel_configuration" "channel" {
  configuration_name = var.configuration_name
  iam_role_arn       = aws_iam_role.chatbot_role.arn
  slack_channel_id   = var.slack_channel_id
  slack_workspace_id = var.slack_workspace_id
  sns_topic_arns     = [aws_sns_topic.chatbot_events.arn]
  logging_level      = "INFO"

  guardrail_policies = [
    "arn:aws:iam::aws:policy/ReadOnlyAccess"
  ]
}
