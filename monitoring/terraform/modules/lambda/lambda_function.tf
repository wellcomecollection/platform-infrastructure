resource "aws_lambda_function" "lambda_function" {
  description   = var.description
  function_name = var.name

  filename         = var.filename
  source_code_hash = filebase64sha256(var.filename)

  role    = aws_iam_role.iam_role.arn
  handler = var.module_name == "" ? "${var.name}.main" : "${var.module_name}.main"
  runtime = "python3.9"
  timeout = var.timeout

  memory_size = var.memory_size

  dead_letter_config {
    target_arn = aws_sqs_queue.lambda_dlq.arn
  }

  environment {
    variables = var.environment_variables
  }
}

resource "aws_cloudwatch_metric_alarm" "lambda_alarm" {
  alarm_name          = "lambda-${var.name}-errors"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = "60"
  statistic           = "Sum"
  threshold           = "1"

  dimensions = {
    FunctionName = var.name
  }

  alarm_description = "This metric monitors lambda errors for function: ${var.name}"
  alarm_actions     = [var.alarm_topic_arn]
}
