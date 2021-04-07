# SNS topic
resource "aws_sns_topic" "sns_invalidation_topic" {
  name = "${var.friendly_name}-cloudfront-invalidate"
}

# Lambda
data "aws_iam_policy_document" "cloudfront_invalidation_exec_role" {
  statement {
    actions = ["sts:AssumeRole", ]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_lambda_permission" "execute_from_sns" {
  statement_id_prefix = "InvalidationExecutionFromSNS"
  action              = "lambda:InvokeFunction"
  function_name       = aws_lambda_function.cloudfront_invalidation.function_name
  principal           = "sns.amazonaws.com"
  source_arn          = aws_sns_topic.sns_invalidation_topic.arn
}

resource "aws_iam_role" "cloudfront_invalidation_exec_role" {
  name_prefix        = "cloudfront_invalidate"
  assume_role_policy = data.aws_iam_policy_document.cloudfront_invalidation_exec_role.json
}

resource "aws_iam_role_policy_attachment" "basic_execution_role" {
  role       = aws_iam_role.cloudfront_invalidation_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_function" "cloudfront_invalidation" {
  function_name = "value"
  role          = aws_iam_role.cloudfront_invalidation_exec_role.arn
  runtime       = "nodejs12.x"
  handler       = "cache_invalidation.handler"
  publish       = true

  s3_bucket         = data.aws_s3_bucket_object.cloudfront_invalidate.bucket
  s3_key            = data.aws_s3_bucket_object.cloudfront_invalidate.key
  s3_object_version = data.aws_s3_bucket_object.cloudfront_invalidate.version_id

  environment {
    variables = {
      DISTRIBUTION_ID = var.distribution_id
    }
  }
}

data "aws_s3_bucket_object" "cloudfront_invalidate" {
  bucket = local.lambda_bucket
  key    = local.lambda_key
}

data "aws_cloudfront_distribution" "distro" {
  id = var.distribution_id
}

data "aws_iam_policy_document" "lambda_invalidate_cloudfront" {
  statement {
    actions = [
      "cloudfront:CreateInvalidation",
      "cloudfront:GetInvalidation",
      "cloudfront:ListInvalidations"
    ]
  }

  resources = [
    data.aws_cloudfront_distribution.distro.arn
  ]
}

resource "aws_iam_role_policy" "lambda_invalidate_cloudfront_distro" {
  name   = "lambda-invalidate-cloudfront-${var.friendly_name}"
  role   = aws_iam_role.cloudfront_invalidation_exec_role.name
  policy = data.aws_iam_policy_document.lambda_invalidate_cloudfront.json
}

# Topic subscription
resource "aws_sns_topic_subscription" "invalidation_lambda_target" {
  topic_arn = aws_sns_topic.sns_invalidation_topic.arn
  protocol  = "lambda"
  endpoint  = aws_sqs_queue.cloudfront_invalidation.arn
}