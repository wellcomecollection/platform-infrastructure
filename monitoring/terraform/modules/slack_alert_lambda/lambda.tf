data "archive_file" "lambda" {
  type        = "zip"
  source_file = "${path.module}/../../../${var.name}/src/${var.name}.py"
  output_path = "${path.module}/${var.name}.zip"
}

resource "aws_s3_bucket_object" "lambda" {
  bucket = var.infra_bucket
  key    = "lambdas/platform-infrastructure/monitoring/${var.name}.zip"
  source = data.archive_file.lambda.output_path

  etag = filemd5(data.archive_file.lambda.output_path)
}

module "lambda" {
  source = "../lambda"

  name        = "${var.account_name}_${var.name}"
  module_name = "${var.name}"
  description = "Sends a notification to Slack when there are 5xx errors from API Gateway"

  timeout = 10

  environment_variables = {
    "ACCOUNT_NAME" = var.account_name
  }

  s3_bucket = aws_s3_bucket_object.lambda.bucket
  s3_key    = aws_s3_bucket_object.lambda.key

  alarm_topic_arn = var.alarm_topic_arn

  depends_on = [aws_s3_bucket_object.lambda]
}

resource "aws_lambda_permission" "allow_sns_trigger" {
  action        = "lambda:InvokeFunction"
  function_name = module.lambda.arn
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.topic.arn
  depends_on    = [aws_sns_topic_subscription.topic_lambda]
}

resource "aws_sns_topic_subscription" "topic_lambda" {
  topic_arn = aws_sns_topic.topic.arn
  protocol  = "lambda"
  endpoint  = module.lambda.arn
}
