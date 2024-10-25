module "slack_chatbot" {
  source = "./modules/chatbot"

  configuration_name = "alerting"
  slack_workspace_id = "TBC"
  slack_channel_id   = "TBC"
}