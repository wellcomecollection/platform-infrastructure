# This sets up CloudFront to S3 logging.
#
# Notes:
#
#   - The S3 bucket lives in the Digirati account so that Digirati can
#     see the logs; these are primarily for their benefit and analysis.
#
#   - The CloudFront distro is in the platform account, so we need to give
#     the platform role permission to set some ACLs on this bucket when
#     it configures the logging.
#

resource "aws_s3_bucket" "cloudfront_logs" {
  bucket = "wellcomecollection-iiif-cloudfront-logs"

  provider = aws.digirati
}

resource "aws_s3_bucket_lifecycle_configuration" "expire_logs_after_30_days" {
  bucket = aws_s3_bucket.cloudfront_logs.id

  rule {
    id     = "cf-logs"
    status = "Enabled"

    expiration {
      days = 30
    }
  }

  provider = aws.digirati
}

data "aws_canonical_user_id" "current" {
  provider = aws.digirati
}

resource "aws_s3_bucket_acl" "allow_cloudfront_access" {
  bucket = aws_s3_bucket.cloudfront_logs.id

  access_control_policy {
    owner {
      id = data.aws_canonical_user_id.current.id
    }

    grant {
      # Grant CloudFront logs access to the Amazon S3 Bucket
      # https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/AccessLogs.html#AccessLogsBucketAndFileOwnership
      grantee {
        id   = "c4c1ede66af53448b93c283ce9448c4ba468c9432aa01d700d3878632f77d2d0"
        type = "CanonicalUser"
      }
      permission = "FULL_CONTROL"
    }

    grant {
      # Grant the platform account full permission to modify this bucket,
      # which it needs to set up CloudFront ~> S3 logs.
      grantee {
        id   = "711c7bddce89222cf7830990b7f0c4c2e8a6ba323b5a2fe4168bfd69e19f1e72"
        type = "CanonicalUser"
      }
      permission = "FULL_CONTROL"
    }
  }

  provider = aws.digirati
}

data "aws_iam_policy_document" "allow_manage_bucket_acl" {
  statement {
    actions = [
      "s3:GetBucketAcl",
      "s3:PutBucketAcl",
    ]

    resources = [
      aws_s3_bucket.cloudfront_logs.id,
    ]
  }
}

resource "aws_iam_role_policy" "allow_platform_to_manage_bucket_acl" {
  role   = "platform-admin"
  policy = data.aws_iam_policy_document.allow_manage_bucket_acl.json
}
