resource "aws_cloudwatch_log_destination" "kinesis" {
  name       = var.name
  role_arn   = aws_iam_role.cloudwatch_to_kinesis_role.arn
  target_arn = aws_kinesis_stream.destination.arn
}

resource "aws_cloudwatch_log_destination_policy" "cross_account_subscriptions" {
  destination_name = aws_cloudwatch_log_destination.kinesis.name
  access_policy    = data.aws_iam_policy_document.cross_account_subscriptions.json
}

data "aws_iam_policy_document" "cross_account_subscriptions" {
  statement {
    effect    = "Allow"
    actions   = ["logs:PutSubscriptionFilter"]
    resources = [aws_cloudwatch_log_destination.kinesis.arn]

    principals {
      identifiers = local.all_account_ids
      type        = "AWS"
    }
  }
}
