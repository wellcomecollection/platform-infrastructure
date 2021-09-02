data "archive_file" "costs_report" {
  type        = "zip"
  source_file = "../costs_report.py"
  output_path = "../costs_report.zip"
}

module "costs_report" {
  source = "../../monitoring/terraform/modules/lambda"

  name        = "costs_report"
  description = "Produces a monthly Slack report of our cloud billing costs"

  filename = data.archive_file.costs_report.output_path

  timeout = 60

  alarm_topic_arn = data.terraform_remote_state.monitoring.outputs.platform_lambda_error_alerts_topic_arn
}
