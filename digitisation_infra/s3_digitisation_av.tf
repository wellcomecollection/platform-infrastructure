resource "aws_s3_bucket" "digitisation_av" {
  bucket = "wellcomecollection-digitisation-av"

  lifecycle_rule {
    id      = "Transition to Infrequent Access"
    enabled = true

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }
  }
}
