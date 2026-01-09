module "slack_alerts_for_5xx" {
  source = "./lambda"

  source_file = "${path.module}/send_slack_alert_for_5xx_errors.js"
  handler     = "send_slack_alert_for_5xx_errors.handler"
  runtime     = "nodejs20.x"

  description = "Send alerts to Slack when there are 5xx alerts in the CloudFront logs"
  name        = "send_slack_alert_for_5xx_errors"

  environment_variables = {
    WEBHOOK_URL       = data.aws_secretsmanager_secret_version.slack_webhook.secret_string
    THRESHOLD_PERCENT = "0.1" # Alert if more than 0.1% of requests are 5xx
  }

  # TODO: We should be able to pull this from the monitoring remote state,
  # but I don't see it defined there.  Is this topic defined in Terraform?
  alarm_topic_arn = data.terraform_remote_state.monitoring.outputs.platform_lambda_error_alerts_topic_arn

  # Note: we used to specify a 30 second timeout here, but occasionally
  # the Lambda would error if there were lots of log events.
  timeout = 300

  memory_size = 256
}

data "aws_secretsmanager_secret_version" "slack_webhook" {
  secret_id = "monitoring/critical_slack_webhook"
}

resource "aws_lambda_permission" "allow_lambda" {
  statement_id  = "AllowExecutionFromS3Bucket_${module.slack_alerts_for_5xx.function_name}"
  action        = "lambda:InvokeFunction"
  function_name = module.slack_alerts_for_5xx.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.cloudfront_logs.arn
}

resource "aws_iam_role_policy" "allow_s3_read" {
  role   = module.slack_alerts_for_5xx.role_name
  policy = data.aws_iam_policy_document.allow_s3_read.json
}

data "aws_iam_policy_document" "allow_s3_read" {
  statement {
    actions = [
      "s3:Get*",
      "s3:List*",
    ]

    resources = [
      aws_s3_bucket.cloudfront_logs.arn,
      "${aws_s3_bucket.cloudfront_logs.arn}/*",
    ]
  }
}
