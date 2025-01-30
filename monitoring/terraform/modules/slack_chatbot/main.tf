resource "aws_sns_topic" "chatbot_events" {
  name = "${var.configuration_name}-chatbot-events"
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
