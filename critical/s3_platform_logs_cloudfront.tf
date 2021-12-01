resource "aws_s3_bucket" "cloudfront_logs" {
  bucket = "wellcomecollection-platform-logs-cloudfront"
  acl    = "private"

  policy = data.aws_iam_policy_document.s3_alb_logs.json

  lifecycle {
    prevent_destroy = true
  }

  lifecycle_rule {
    id      = "expire_cloudfront_logs"
    enabled = true

    expiration {
      days = 30
    }
  }
}

data "aws_iam_policy_document" "s3_cloudfront_logs" {
  statement {
    actions = [
      "s3:*",
    ]

    resources = [
      aws_s3_bucket.cloudfront_logs.arn,
      "${aws_s3_bucket.cloudfront_logs.arn}/*",
    ]

    principals {
      identifiers = ["arn:aws:iam::${local.account_ids["experience"]}:root"]
      type        = "AWS"
    }
  }
}
