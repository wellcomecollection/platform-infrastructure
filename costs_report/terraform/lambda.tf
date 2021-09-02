data "archive_file" "costs_report" {
  type        = "zip"
  source_dir  = "../costs_report"
  output_path = "../costs_report.zip"

  excludes = [
    "../costs_report/__pycache__"
  ]
}

module "costs_report_lambda" {
  source = "../../monitoring/terraform/modules/lambda"

  name        = "costs_report"
  description = "Produces a monthly Slack report of our cloud billing costs"

  filename = data.archive_file.costs_report.output_path

  timeout = 60

  alarm_topic_arn = local.lambda_error_alerts_topic_arn
}
