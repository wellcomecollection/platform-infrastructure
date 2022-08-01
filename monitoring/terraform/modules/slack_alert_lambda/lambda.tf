locals {
  source_name = var.source_name != "" ? var.source_name : var.name
}

data "archive_file" "lambda" {
  type        = "zip"
  source_dir  = "${path.module}/../../../slack_alerts/${local.source_name}/src"
  output_path = "${path.module}/${local.source_name}.zip"
}

module "lambda" {
  source = "../lambda"

  name        = "${var.account_name}_${var.name}"
  module_name = local.source_name
  description = var.description

  timeout = 10

  environment_variables = merge(
    {
      "ACCOUNT_NAME" = var.account_name
    },
    var.environment_variables
  )

  filename = data.archive_file.lambda.output_path

  alarm_topic_arn = var.alarm_topic_arn
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
