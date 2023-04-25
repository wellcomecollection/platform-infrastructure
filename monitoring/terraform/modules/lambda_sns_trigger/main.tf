variable "lambda_arn" {
  type = string
}

variable "topic_name" {
  type = string
}

resource "aws_sns_topic" "topic" {
  name = var.topic_name
}

output "topic_arn" {
  value = aws_sns_topic.topic.arn
}

resource "aws_lambda_permission" "allow_sns_trigger" {
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_arn
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.topic.arn
  depends_on    = [aws_sns_topic_subscription.sns_to_lambda]
}

resource "aws_sns_topic_subscription" "sns_to_lambda" {
  topic_arn = aws_sns_topic.topic.arn
  protocol  = "lambda"
  endpoint  = var.lambda_arn
}
