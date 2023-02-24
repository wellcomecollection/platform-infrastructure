resource "aws_s3_bucket" "dashboard" {
  bucket = "wellcomecollection-platform-dashboard"
}

resource "aws_s3_bucket_acl" "dashboard" {
  bucket = aws_s3_bucket.dashboard.id
  acl    = "public-read"
}

resource "aws_s3_bucket_cors_configuration" "dashboard" {
  bucket = aws_s3_bucket.dashboard.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET"]
    allowed_origins = ["*"]
    expose_headers  = ["ETag"]
    max_age_seconds = 3000
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "dashboard" {
  bucket = aws_s3_bucket.dashboard.id

  rule {
    id     = "budget_graphs"
    status = "Enabled"

    filter {
      prefix = "budget_graphs/"
    }

    expiration {
      days = 30
    }
  }
}