data "archive_file" "dlq_to_slack_alerts" {
  type        = "zip"
  source_file = "${path.module}/../../../dlq_to_slack_alerts/src/dlq_to_slack_alerts.py"
  output_path = "${path.module}/dlq_to_slack_alerts.zip"
}

resource "aws_s3_bucket_object" "lambda" {
  bucket = var.infra_bucket
  key    = "lambdas/platform-infrastructure/monitoring/dlq_to_slack_alerts.zip"
  source = data.archive_file.dlq_to_slack_alerts.output_path

  etag = filemd5(data.archive_file.dlq_to_slack_alerts.output_path)
}

module "lambda" {
  source = "../lambda"

  name        = "dlq_to_slack_alerts"
  description = "Sends a notification to Slack when there are messages on DLQs"

  timeout = 10

  s3_bucket = aws_s3_bucket_object.lambda.bucket
  s3_key    = aws_s3_bucket_object.lambda.key

  alarm_topic_arn = var.alarm_topic_arn

  depends_on = [aws_s3_bucket_object.lambda]
}

resource "aws_lambda_permission" "allow_sns_trigger" {
  action        = "lambda:InvokeFunction"
  function_name = module.lambda.arn
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.dlq_alarms.arn
  depends_on    = [aws_sns_topic_subscription.topic_lambda]
}

resource "aws_sns_topic_subscription" "topic_lambda" {
  topic_arn = aws_sns_topic.dlq_alarms.arn
  protocol  = "lambda"
  endpoint  = module.lambda.arn
}
