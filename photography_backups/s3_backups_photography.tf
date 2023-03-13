resource "aws_s3_bucket" "photography_backups" {
  bucket = "wellcomecollection-backups-photography"

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_acl" "photography_backups" {
  bucket = aws_s3_bucket.photography_backups.id
  acl    = "private"
}
