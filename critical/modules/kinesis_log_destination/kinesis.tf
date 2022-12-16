resource "aws_kinesis_stream" "destination" {
  name = var.name

  enforce_consumer_deletion = true
  encryption_type           = "NONE"
  retention_period          = 3 * 24 // Give us 3 days to deal with issues ingesting logs

  stream_mode_details {
    stream_mode = "ON_DEMAND"
  }
}

resource "aws_iam_role" "cloudwatch_to_kinesis_role" {
  name = "${var.name}-role"
  assume_role_policy = data.aws_iam_policy_document.cloudwatch_assume_role.json
}

resource "aws_iam_role_policy" "kinesis_put_record" {
  name = "kinesis-put-record-${var.name}"
  role = aws_iam_role.cloudwatch_to_kinesis_role.name
  policy = data.aws_iam_policy_document.kinesis_put_record.json
}

data "aws_iam_policy_document" "cloudwatch_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["logs.amazonaws.com"]
    }

    condition {
      test     = "StringLike"
      variable = "aws:SourceArn"
      values   = [for id in local.all_account_ids : "arn:aws:logs:${data.aws_region.current.name}:${id}:*"]
    }
  }
}

data "aws_iam_policy_document" "kinesis_put_record" {
  statement {
    effect = "Allow"
    actions = ["kinesis:PutRecord"]
    resources = [aws_kinesis_stream.destination.arn]
  }
}

locals {
  all_account_ids = setunion(var.source_account_ids, [data.aws_caller_identity.current.account_id])
}

data "aws_region" "current" {}
data "aws_caller_identity" "current" {}
