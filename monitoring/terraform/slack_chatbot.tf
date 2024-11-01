module "slack_chatbot" {
  source = "./modules/slack_chatbot"

  configuration_name = "alerting"
  slack_workspace_id = data.aws_ssm_parameter.slack_workspace_id.value
  slack_channel_id   = data.aws_ssm_parameter.slack_channel_id.value
}

data "aws_ssm_parameter" "slack_workspace_id" {
  name = "/platform/alert_chatbot/workspace_id"
}

data "aws_ssm_parameter" "slack_channel_id" {
  name = "/platform/alert_chatbot/channel_id"
}