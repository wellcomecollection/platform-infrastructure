# Chatbot IAM roles and policies

resource "aws_iam_role" "chatbot_role" {
  name = "${var.configuration_name}-chatbot-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "chatbot.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

data "aws_iam_policy_document" "cloudwatch_read" {
  statement {
    actions = [
      "cloudwatch:Describe*",
      "cloudwatch:Get*",
      "cloudwatch:List*",
    ]
    effect    = "Allow"
    resources = ["*"]
  }
}

resource "aws_iam_policy" "cloudwatch_read" {
  name        = "${var.configuration_name}-cloudwatch_read"
  description = "Allow read access to CloudWatch"
  policy      = data.aws_iam_policy_document.cloudwatch_read.json
}

resource "aws_iam_role_policy_attachment" "chatbot_role_policy" {
  role       = aws_iam_role.chatbot_role.name
  policy_arn = aws_iam_policy.cloudwatch_read.arn
}

# SNS Topic Policy
data "aws_caller_identity" "platform" {
    provider = aws.platform
}
data "aws_caller_identity" "experience" {
  provider = aws.experience
}

data "aws_iam_policy_document" "sns_topic_policy" {
  statement {
    effect  = "Allow"
    actions = ["SNS:Publish"]
    principals {
      type        = "Service"
      identifiers = ["cloudwatch.amazonaws.com"]
    }
    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [
        data.aws_caller_identity.platform.account_id,
        data.aws_caller_identity.experience.account_id
      ]
    }
    resources = [aws_sns_topic.chatbot_events.arn]
  }
}

resource "aws_sns_topic_policy" "default" {
  arn    = aws_sns_topic.chatbot_events.arn
  policy = data.aws_iam_policy_document.sns_topic_policy.json
}

