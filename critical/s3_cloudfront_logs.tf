resource "aws_s3_bucket" "api_root_cf_logs" {
  bucket = "weco-cloudfront-logs"

  policy = data.aws_iam_policy_document.s3_cloudfront_logs.json

  lifecycle_rule {
    id      = "cf-logs"
    prefix  = ""
    enabled = true

    expiration {
      days = 30
    }
  }

  grant {
    # Grant CloudFront logs access to your Amazon S3 Bucket
    # https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/AccessLogs.html#AccessLogsBucketAndFileOwnership
    id          = "c4c1ede66af53448b93c283ce9448c4ba468c9432aa01d700d3878632f77d2d0"
    permissions = ["FULL_CONTROL"]
    type        = "CanonicalUser"
  }
}

data "aws_iam_policy_document" "s3_cloudfront_logs" {
  statement {
    actions = [
      "s3:*",
    ]

    resources = [
      "arn:aws:s3:::weco-cloudfront-logs",
      "arn:aws:s3:::weco-cloudfront-logs/*"
    ]

    principals {
      identifiers = [
        "arn:aws:iam::${local.account_ids["experience"]}:root"
      ]

      type = "AWS"
    }
  }
}
