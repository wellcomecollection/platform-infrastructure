resource "aws_sns_topic" "chatbot_events" {
  name = "${var.configuration_name}-chatbot-events"
}

resource "aws_cloudwatch_event_rule" "cloudwatch_alarms_alarm_state" {
  name        = "${var.configuration_name}-alarm-state-cloudwatch"
  description = "Rule to send CloudWatch Alarms to Chatbot"

  event_pattern = jsonencode({
    source      = ["aws.cloudwatch"]
    detail-type = ["CloudWatch Alarm State Change"]
    detail      = {
      alarmName = [{
        "wildcard": "${var.alarm_match_string}"
      }]
      state = {
        value = ["ALARM"]
      }
    }
  })
}

resource "aws_cloudwatch_event_target" "sns_chatbot_custom_alarm_state" {
  rule = aws_cloudwatch_event_rule.cloudwatch_alarms_alarm_state.name
  arn  = aws_sns_topic.chatbot_events.arn
  input_transformer {
    input_paths    = local.input_paths
    input_template = local.input_template_alarm
  }
}

resource "aws_cloudwatch_event_rule" "cloudwatch_alarms_ok_state" {
  name        = "${var.configuration_name}-ok-state-cloudwatch"
  description = "Rule to send CloudWatch Alarms to Chatbot"

  event_pattern = jsonencode({
    source      = ["aws.cloudwatch"]
    detail-type = ["CloudWatch Alarm State Change"]
    detail      = {
      alarmName = [{
        "wildcard": "${var.alarm_match_string}"
      }]
      state = {
        value = ["OK"]
      }
    }
  })
}

resource "aws_cloudwatch_event_target" "sns_chatbot_custom_ok_state" {
  rule = aws_cloudwatch_event_rule.cloudwatch_alarms_ok_state.name
  arn  = aws_sns_topic.chatbot_events.arn
  input_transformer {
    input_paths    = local.input_paths
    input_template = local.input_template_ok
  }
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
