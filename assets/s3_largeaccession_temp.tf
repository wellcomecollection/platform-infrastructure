resource "aws_s3_bucket" "large_accession_temp" {
  bucket = "wellcomecollection-assets-largeaccessiontemp"

  lifecycle {
    prevent_destroy = true
  }

  tags = local.default_tags
}

# Enable versioning on the bucket
resource "aws_s3_bucket_versioning" "large_accession_temp" {
  bucket = aws_s3_bucket.large_accession_temp.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "large_accession_temp" {
  bucket = aws_s3_bucket.large_accession_temp.id

  # Transition all objects to Glacier Instant Retrieval storage class immediately
  rule {
    id = "transition_all_to_glacier_instant"

    transition {
      days          = 0
      storage_class = "GLACIER_IR"
    }

    status = "Enabled"
  }

  # Delete non-current versions after 30 days
  rule {
    id = "delete_non_current_versions_after_30_days"

    noncurrent_version_expiration {
      noncurrent_days = 30
    }

    status = "Enabled"
  }
}

# Provision an IAM user for cataloguers to access the large accession temp bucket
resource "aws_iam_user" "cataloguers_large_accession_temp" {
  name = "cataloguers_large_accession_temp"

  tags = local.default_tags
}

# Allow access for sync, but prevent deletion of non-current versions
data "aws_iam_policy_document" "allow_large_accession_temp_access" {
  statement {
    sid    = "AllowAllS3ActionsInsideBucket"
    effect = "Allow"
    actions = [
      "s3:*",
    ]
    resources = [
      "arn:aws:s3:::wellcomecollection-assets-largeaccessiontemp/*", # For object-level actions
    ]
  }

  statement {
    sid    = "DenyPermanentDeletionOfObjectVersions"
    effect = "Deny"
    actions = [
      "s3:DeleteObjectVersion",
    ]
    resources = [
      "arn:aws:s3:::wellcomecollection-assets-largeaccessiontemp/*", # This action applies to objects
    ]
  }

  statement {
    sid    = "AllowGetS3ActionsOnBucket"
    effect = "Allow"
    actions = [
      "s3:Get*",
      "s3:List*",
    ]
    resources = [
      "arn:aws:s3:::wellcomecollection-assets-largeaccessiontemp", # For bucket-level actions
    ]
  }
}

resource "aws_iam_user_policy" "cataloguers_large_accession_temp" {
  user   = aws_iam_user.cataloguers_large_accession_temp.name
  policy = data.aws_iam_policy_document.allow_large_accession_temp_access.json
}
