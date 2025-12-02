module "slack_chatbot" {
  source = "./modules/slack_chatbot"

  configuration_name = "alerting"
  slack_workspace_id = data.aws_ssm_parameter.slack_workspace_id.value
  slack_channel_id   = data.aws_ssm_parameter.slack_channel_id.value

  providers = {
    aws.platform   = aws.platform
    aws.experience = aws.experience
  }
}

module "slack_chatbot_testing" {
  source = "./modules/slack_chatbot"

  configuration_name = "testing-alerting"
  slack_workspace_id = data.aws_ssm_parameter.slack_workspace_id.value
  slack_channel_id   = data.aws_ssm_parameter.slack_channel_id_testing.value

  providers = {
    aws.platform   = aws.platform
    aws.experience = aws.experience
  }
}


data "aws_ssm_parameter" "slack_workspace_id" {
  name = "/platform/alert_chatbot/workspace_id"
}

data "aws_ssm_parameter" "slack_channel_id" {
  name = "/platform/alert_chatbot/channel_id"
}

data "aws_ssm_parameter" "slack_channel_id_testing" {
  name = "/platform/alert_chatbot/testing_channel_id"
}