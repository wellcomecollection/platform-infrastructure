resource "aws_s3_bucket" "digitisation_transfer" {
  bucket = "wellcomecollection-digitisation-transfer"
}

resource "aws_s3_bucket_lifecycle_configuration" "digitisation_transfer" {
  bucket = aws_s3_bucket.digitisation_transfer.id

  rule {
    id     = "Transition to Infrequent Access"
    status = "Enabled"

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }
  }
}
