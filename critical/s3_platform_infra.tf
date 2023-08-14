resource "aws_s3_bucket" "platform_infra" {
  bucket = "wellcomecollection-platform-infra"

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_acl" "platform_infra" {
  bucket = aws_s3_bucket.platform_infra.id
  acl    = "private"
}

resource "aws_s3_bucket_lifecycle_configuration" "platform_infra" {
  bucket = aws_s3_bucket.platform_infra.id

  rule {
    id = "tmp"

    filter {
      prefix = "tmp/"
    }

    expiration {
      days = 30
    }

    status = "Enabled"
  }

  rule {
    id = "expire_old_versions"

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    noncurrent_version_expiration {
      noncurrent_days = 90
    }

    status = "Enabled"
  }
}

resource "aws_s3_bucket_versioning" "platform_infra" {
  bucket = aws_s3_bucket.platform_infra.id

  versioning_configuration {
    status = "Enabled"
  }
}
